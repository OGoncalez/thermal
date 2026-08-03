# TempControl - Sistema IoT de Monitoramento de Temperatura

## ✅ Configuração Completa

### 1. Database Supabase
Suas credenciais já estão nos arquivos HTML:
- **URL:** `https://rvcngfxogapncxdihcrz.supabase.co`
- **Chave Anônima:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2Y25nZnhvZ2FwbmN4ZGloY3J6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0ODI3MDAsImV4cCI6MTc1NjA2MDcwMH0.LWy_lX0hQoqFVMKVUQTaBPJ4UblbjBqA6LD9nO0VNgw`

### 2. Tabelas SQL
Execute este script no SQL Editor do Supabase:

```sql
CREATE TABLE public.users (
  id uuid NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

CREATE TABLE public.devices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  device_name character varying NOT NULL,
  device_type character varying DEFAULT 'temperature_sensor'::character varying,
  min_temp numeric DEFAULT 0,
  max_temp numeric DEFAULT 50,
  location character varying,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT devices_pkey PRIMARY KEY (id),
  CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

CREATE TABLE public.temperature_readings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  device_id uuid NOT NULL,
  temperature numeric NOT NULL,
  humidity numeric,
  status character varying DEFAULT 'normal'::character varying,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT temperature_readings_pkey PRIMARY KEY (id),
  CONSTRAINT temperature_readings_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id)
);

CREATE TABLE public.alerts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  device_id uuid NOT NULL,
  user_id uuid NOT NULL,
  message text NOT NULL,
  alert_type character varying,
  is_read boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT alerts_pkey PRIMARY KEY (id),
  CONSTRAINT alerts_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id),
  CONSTRAINT alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

### 3. Row Level Security (RLS)

Enable RLS em todas as tabelas:

```sql
-- Habilitar RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.temperature_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

-- Policies para users
CREATE POLICY "Users can view own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Policies para devices
CREATE POLICY "Users can view own devices" ON public.devices
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create devices" ON public.devices
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policies para temperature_readings
CREATE POLICY "Users can view readings from own devices" ON public.temperature_readings
  FOR SELECT USING (
    device_id IN (SELECT id FROM devices WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can insert readings to own devices" ON public.temperature_readings
  FOR INSERT WITH CHECK (
    device_id IN (SELECT id FROM devices WHERE user_id = auth.uid())
  );

-- Policies para alerts
CREATE POLICY "Users can view own alerts" ON public.alerts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create alerts" ON public.alerts
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 4. Configurar Wokwi

Seu código ESP32 publica no tópico MQTT: `iot/otavio`

O dashboard se conecta automaticamente ao broker MQTT público: `wss://broker.emqx.io:8084/mqtt`

### 5. Fluxo de Uso

1. Abra `index.html` - Página inicial
2. Clique em "Cadastre-se aqui" ou botão de cadastro
3. Preencha nome, email e senha (mín 6 chars, 1 maiúscula, 1 número)
4. Um dispositivo padrão será criado automaticamente
5. Faça login com seu email e senha
6. Você será redirecionado ao dashboard
7. O dashboard se conectará ao MQTT e exibirá temperaturas em tempo real

### 6. Estrutura dos Arquivos

```
├── index.html          - Página inicial
├── login.html          - Tela de login
├── signup.html         - Tela de cadastro
├── dashboard.html      - Dashboard com MQTT
├── schema.sql          - Script SQL (já está nas tabelas acima)
└── INSTRUCOES.md       - Este arquivo
```

### 7. Status do Sistema

✅ **Autenticação:** Supabase Auth completo
✅ **Database:** 4 tabelas com RLS
✅ **MQTT:** Conectado ao broker EMQX público
✅ **Redirecionamentos:** Login → Dashboard, Signup → Login
✅ **Criar Dispositivo:** Automático no signup
✅ **Gráficos:** Chart.js com histórico de 24 horas
✅ **Alertas:** Automáticos quando temp > max
✅ **Design:** Tema escuro moderno com gradientes

### 8. Troubleshooting

**Erro ao fazer login:**
- Verifique se criou a tabela `users` no SQL Editor
- Certifique-se de estar usando as mesmas credenciais

**Dashboard não carrega:**
- Abra DevTools (F12) e procure por erros de console
- Verifique se a sessão Supabase está ativa

**MQTT não conecta:**
- O broker EMQX é público e gratuito
- Seu ESP32 deve estar publicando em `iot/otavio`
- Dashboard espera mensagens numéricas (temperatura)

**Nenhum dispositivo aparece:**
- Faça um novo cadastro - ele cria automaticamente um
- Ou insira manualmente na tabela `devices` do Supabase

---

**Tudo pronto! 🚀 Abra `index.html` e comece a usar!**
