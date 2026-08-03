-- ==========================================
-- TABELA DE USUÁRIOS (Auth)
-- ==========================================
-- Use a autenticação nativa do Supabase
-- Ela cria a tabela 'auth.users' automaticamente

-- ==========================================
-- TABELA DE DISPOSITIVOS IoT
-- ==========================================
CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  device_type VARCHAR(50) DEFAULT 'temperature_sensor',
  location VARCHAR(255),
  min_temp FLOAT DEFAULT 0,
  max_temp FLOAT DEFAULT 50,
  alert_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_devices_user_id ON devices(user_id);

-- ==========================================
-- TABELA DE LEITURAS DE TEMPERATURA
-- ==========================================
CREATE TABLE temperature_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  temperature FLOAT NOT NULL,
  humidity FLOAT,
  status VARCHAR(20) DEFAULT 'normal', -- 'normal', 'warning', 'critical'
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_readings_device_id ON temperature_readings(device_id);
CREATE INDEX idx_readings_timestamp ON temperature_readings(timestamp);

-- ==========================================
-- TABELA DE ALERTAS
-- ==========================================
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  temperature FLOAT NOT NULL,
  alert_type VARCHAR(20), -- 'high', 'low', 'critical'
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_device_id ON alerts(device_id);
CREATE INDEX idx_alerts_is_read ON alerts(is_read);

-- ==========================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE temperature_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- RLS POLICY: Usuários só podem ver seus próprios dispositivos
CREATE POLICY devices_user_isolation ON devices
  FOR ALL USING (auth.uid() = user_id);

-- RLS POLICY: Usuários só podem ler leituras de seus dispositivos
CREATE POLICY readings_user_isolation ON temperature_readings
  FOR ALL USING (
    device_id IN (SELECT id FROM devices WHERE user_id = auth.uid())
  );

-- RLS POLICY: Usuários só podem ver seus próprios alertas
CREATE POLICY alerts_user_isolation ON alerts
  FOR ALL USING (auth.uid() = user_id);

-- ==========================================
-- FUNÇÃO PARA ATUALIZAR UPDATED_AT
-- ==========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_devices_updated_at
  BEFORE UPDATE ON devices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
