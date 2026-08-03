## 🌡️ Thermite - Sistema de Monitoramento IoT

Sistema completo de monitoramento de temperatura em tempo real com integração MQTT, autenticação Supabase e dashboard interativo.

---

## 📋 Arquivos do Projeto

- `index.html` - Página inicial com features e informações
- `login.html` - Página de login
- `signup.html` - Página de cadastro com validação de senha
- `dashboard.html` - Dashboard principal com monitoramento em tempo real
- `schema.sql` - Script SQL para criar tabelas no Supabase
- `README.md` - Este arquivo

---

## 🚀 Como Configurar

### 1. Configurar Supabase

1. Acesse [supabase.com](https://supabase.com) e crie uma nova conta
2. Crie um novo projeto
3. Vá para o SQL Editor e execute o script `schema.sql`:
   - Copie todo o conteúdo do arquivo `schema.sql`
   - Cole no SQL Editor do Supabase
   - Clique em "Run"

### 2. Obter Credenciais Supabase

1. No painel do Supabase, vá para "Project Settings"
2. Na aba "API", copie:
   - **Project URL** (salve como SUPABASE_URL)
   - **anon public key** (salve como SUPABASE_ANON_KEY)

### 3. Atualizar Credenciais nos Arquivos

Abra cada arquivo HTML e procure por:
```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co'; // Alterar
const SUPABASE_ANON_KEY = 'sua-chave-anonima'; // Alterar
```

Substitua pelos valores que você copiou:

**login.html:**
```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'SuaChaveAquiXXXXX...';
```

**signup.html:**
```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'SuaChaveAquiXXXXX...';
```

**dashboard.html:**
```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'SuaChaveAquiXXXXX...';
```

### 4. Configurar Wokwi (ESP32)

Seu código ESP32 no Wokwi já está configurado para publicar no tópico MQTT `iot/otavio`. 

O dashboard está configurado para:
- Conectar ao broker MQTT público: `wss://broker.emqx.io:8084/mqtt`
- Inscrever no tópico: `iot/otavio`
- Receber temperaturas em tempo real

---

## 📱 Como Usar

### 1. Acesso Inicial
- Abra `index.html` no navegador
- Veja a página inicial com informações sobre o sistema

### 2. Criar Conta
- Clique em "Cadastro"
- Preencha nome completo, email e senha (mínimo 6 caracteres, com letra maiúscula e número)
- A senha será validada em tempo real
- Clique em "Criar Conta"

### 3. Fazer Login
- Clique em "Login"
- Informe email e senha
- Será redirecionado para o dashboard

### 4. Dashboard
- Visualize dispositivos com temperatura atual
- Veja status automático: 🟢 Normal, 🟡 Aviso, 🔴 Crítico
- Gráfico atualiza com histórico de 24 últimas leituras
- Alertas aparecem automaticamente quando temperatura atinge limites
- Status MQTT mostra conexão com o broker

---

## 🔌 Integração com Wokwi

### Seu código ESP32 está publicando:
```cpp
// Tópico: iot/otavio
// Tipo: temperatura em Celsius
// Frequência: a cada 3 segundos
```

### Dashboard recebe:
1. Mensagem MQTT com temperatura
2. Identifica o dispositivo do usuário
3. Salva no Supabase
4. Define status automático
5. Cria alertas se necessário
6. Atualiza gráfico e UI

---

## 🗄️ Estrutura do Banco de Dados

### Tabelas:

**users**
- id (UUID) - ID do usuário
- email - Email único
- full_name - Nome completo
- created_at - Data de criação

**devices**
- id (UUID) - ID do dispositivo
- user_id - Referência ao usuário
- device_name - Nome do dispositivo
- device_type - Tipo (ex: temperature_sensor)
- min_temp - Temperatura mínima permitida
- max_temp - Temperatura máxima permitida
- location - Localização do sensor
- is_active - Se está ativo
- created_at - Data de criação

**temperature_readings**
- id (UUID) - ID da leitura
- device_id - Referência ao dispositivo
- temperature - Temperatura em °C
- humidity - Umidade em %
- status - normal/warning/critical
- created_at - Data/hora da leitura

**alerts**
- id (UUID) - ID do alerta
- device_id - Referência ao dispositivo
- user_id - Referência ao usuário
- message - Mensagem do alerta
- alert_type - warning/critical
- is_read - Se foi lido
- created_at - Data/hora do alerta

---

## 🔒 Segurança

- ✅ Autenticação com Supabase Auth
- ✅ Row Level Security (RLS) em todas as tabelas
- ✅ Validação de senha no cadastro
- ✅ Sessão segura no dashboard
- ✅ Dados encriptados no Supabase

---

## 🌐 Conectividade MQTT

**Broker Público Usado:** EMQX
- URL: `wss://broker.emqx.io:8084/mqtt`
- Protocolo: MQTT over WebSocket (wss://)
- Tópico: `iot/otavio`

**Como Funciona:**
1. ESP32 publica temperatura no MQTT
2. Dashboard se inscreve no tópico
3. Recebe mensagens em tempo real
4. Salva no Supabase + atualiza UI

---

## 🐛 Troubleshooting

### Problema: "Erro ao conectar ao Supabase"
- Verifique se as credenciais estão corretas
- Confirme que a URL termina com `.co` (não `.com`)
- Verifique se o projeto está criado no Supabase

### Problema: "MQTT desconectado"
- O broker público está indisponível? Tente recarregar a página
- Verifique conexão de internet
- O Wokwi está rodando e publicando dados?

### Problema: "Sem dados no gráfico"
- Aguarde 30 segundos para o Wokwi gerar dados
- Verifique se o tópico MQTT é exatamente `iot/otavio`
- Confirme se o dashboard está conectado ao MQTT (status verde)

### Problema: "Alertas não aparecem"
- Defina temperaturas realistas no dispositivo (min/max)
- Verifique se a temperatura está ultrapassando os limites configurados
- Recarregue a página para ver alertas novos

---

## 📝 Criar Dispositivos via SQL

Se quiser adicionar um dispositivo manualmente no Supabase:

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

Para encontrar seu `user_id`:
1. Vá para "Database" → "Auth" no Supabase
2. Copie o UUID do seu usuário

---

## 🎯 Próximos Passos

- [ ] Configurar Supabase
- [ ] Executar script SQL
- [ ] Atualizar credenciais nos arquivos HTML
- [ ] Testar com Wokwi
- [ ] Acessar dashboard
- [ ] Ver dados chegando em tempo real!

---

## 💡 Dicas

- Use o painel do Supabase para inspecionar dados
- Abra o Console do navegador (F12) para ver logs [v0]
- Experimente mudar o min_temp e max_temp do dispositivo
- Teste criar múltiplos usuários

---

Desenvolvido com ❤️ para monitoramento IoT em tempo real!
