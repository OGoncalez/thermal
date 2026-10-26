## Thermite - Sistema de Monitoramento IoT

Sistema completo de monitoramento de temperatura em tempo real com integração MQTT, autenticação Supabase e dashboard interativo.


##  Arquivos do Projeto

## Thermite - Sistema de Monitoramento IoT

Sistema de monitoramento de temperatura em tempo real com integração MQTT, autenticação via Supabase e dashboard web.



## Arquivos do projeto

- `index.html` — Página inicial
- `login.html` — Página de login
- `signup.html` — Página de cadastro
- `dashboard.html` — Dashboard com monitoramento em tempo real
- `schema.sql` — Script SQL para criar as tabelas no Supabase
- `README.md` — Documentação do projeto

---

## Configuração

1. Criar uma conta e projeto no Supabase: https://supabase.com
2. No SQL Editor do Supabase, executar o arquivo `schema.sql`.
3. Obter as credenciais do projeto em Project Settings → API:
   - Project URL (salvar como `SUPABASE_URL`)
   - anon public key (salvar como `SUPABASE_ANON_KEY`)
4. Atualizar as constantes `SUPABASE_URL` e `SUPABASE_ANON_KEY` em `login.html`, `signup.html` e `dashboard.html`.

Exemplo:
```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'SuaChaveAquiXXXXX...';
```

---

## Integração MQTT (Wokwi / ESP32)

- Broker WebSocket: `wss://broker.emqx.io:8084/mqtt`
- Tópico usado: `iot/otavio`

O dispositivo ESP32 publica mensagens de temperatura. O dashboard se inscreve no tópico MQTT, recebe as mensagens em tempo real e as persiste no Supabase conforme a lógica do projeto.

Exemplo de payload esperado (informativo):
```cpp
// Tópico: iot/otavio
// Tipo: temperatura em Celsius
// Frequência: a cada 3 segundos
```

---

## Uso básico

1. Abrir `index.html` no navegador.
2. Criar conta em `signup.html` e realizar login em `login.html`.
3. Acessar `dashboard.html` para visualizar leituras e histórico.

O dashboard apresenta o estado dos dispositivos, histórico de leituras e alertas configurados pelo usuário.

---

## Estrutura do banco de dados

Tabelas principais:

- `users` (id UUID, email, full_name, created_at)
- `devices` (id UUID, user_id, device_name, device_type, min_temp, max_temp, location, is_active, created_at)
- `temperature_readings` (id UUID, device_id, temperature, humidity, status, created_at)
- `alerts` (id UUID, device_id, user_id, message, alert_type, is_read, created_at)

---

## Segurança

- Autenticação via Supabase Auth
- Row Level Security (RLS) configurada nas tabelas
- Validação de entrada no front-end

---

## Conectividade MQTT

- Broker: EMQX
- URL: `wss://broker.emqx.io:8084/mqtt`
- Tópico: `iot/otavio`

Fluxo resumido:
1. ESP32 publica temperatura no MQTT.
2. Dashboard se inscreve no tópico e processa as mensagens.
3. Leituras são persistidas no Supabase e exibidas na UI.

---

## Troubleshooting

- Erro ao conectar ao Supabase: verificar `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
- MQTT desconectado: verificar disponibilidade do broker e conexão de rede.
- Sem dados no gráfico: confirmar tópico MQTT e se o dispositivo está publicando mensagens.

---

## Inserir dispositivos via SQL

Exemplo de inserção manual:
```sql
INSERT INTO devices (user_id, device_name, device_type, min_temp, max_temp, location, is_active)
VALUES (
  'seu-user-id-aqui',
  'Sensor Sala',
  'temperature_sensor',
  15,
  30,
  'Sala de Estar',
  true
);
```

Para encontrar o `user_id`, verificar o painel de Auth no Supabase.

---

## Próximos passos

- Configurar Supabase
- Executar script SQL
- Atualizar credenciais nos arquivos HTML
- Testar integração com Wokwi
- Verificar fluxo de dados no dashboard
