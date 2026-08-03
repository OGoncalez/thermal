-- Criar tabela de usuários (já existe no Supabase Auth, mas vamos criar a referência)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Criar tabela de dispositivos
CREATE TABLE IF NOT EXISTS devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_name VARCHAR(255) NOT NULL,
  device_type VARCHAR(100) DEFAULT 'temperature_sensor',
  min_temp DECIMAL(5,2) DEFAULT 0,
  max_temp DECIMAL(5,2) DEFAULT 50,
  location VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Criar tabela de leituras de temperatura
CREATE TABLE IF NOT EXISTS temperature_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  temperature DECIMAL(6,2) NOT NULL,
  humidity DECIMAL(5,2),
  status VARCHAR(20) DEFAULT 'normal', -- normal, warning, critical
  created_at TIMESTAMP DEFAULT NOW()
);

-- Criar tabela de alertas
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  alert_type VARCHAR(20), -- warning, critical
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_temperature_readings_device_id ON temperature_readings(device_id);
CREATE INDEX idx_temperature_readings_created_at ON temperature_readings(created_at DESC);
CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_device_id ON alerts(device_id);
CREATE INDEX idx_alerts_is_read ON alerts(is_read);

-- Habilitar Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE temperature_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para users
CREATE POLICY "Usuários podem ver seus próprios dados" ON users
  FOR SELECT USING (auth.uid() = id);

-- Políticas RLS para devices
CREATE POLICY "Usuários podem ver seus próprios dispositivos" ON devices
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar dispositivos" ON devices
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus dispositivos" ON devices
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seus dispositivos" ON devices
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas RLS para temperature_readings
CREATE POLICY "Usuários podem ver leituras de seus dispositivos" ON temperature_readings
  FOR SELECT USING (
    device_id IN (
      SELECT id FROM devices WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Sistema pode inserir leituras de temperatura" ON temperature_readings
  FOR INSERT WITH CHECK (
    device_id IN (
      SELECT id FROM devices WHERE user_id = auth.uid()
    )
  );

-- Políticas RLS para alerts
CREATE POLICY "Usuários podem ver seus próprios alertas" ON alerts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Sistema pode criar alertas" ON alerts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus alertas" ON alerts
  FOR UPDATE USING (auth.uid() = user_id);
