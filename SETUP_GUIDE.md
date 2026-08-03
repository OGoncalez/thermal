# 🚀 Guia de Configuração - TempMonitor IoT

## 1️⃣ Configurar Supabase

### 1.1 Criar Projeto
1. Acesse [supabase.com](https://supabase.com)
2. Faça login ou crie uma conta
3. Clique em "New Project"
4. Escolha um nome e configure a senha

### 1.2 Executar Schema SQL
1. No painel do Supabase, vá para **SQL Editor**
2. Clique em **New Query**
3. Copie todo o conteúdo do arquivo `supabase-schema.sql`
4. Cole no editor e clique em **Run**

### 1.3 Obter Credenciais
1. Vá para **Project Settings** > **API**
2. Copie:
   - **Project URL** (ex: `https://xxxxx.supabase.co`)
   - **anon public** key

### 1.4 Atualizar Arquivos
Abra cada arquivo e substitua as credenciais:

**Em `login.html`, `signup.html` e `dashboard.html`:**
```javascript
const SUPABASE_URL = 'sua-url-aqui';
const SUPABASE_ANON_KEY = 'sua-chave-aqui';
```

**Exemplo:**
```javascript
const SUPABASE_URL = 'https://abcdef123456.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 2️⃣ Configurar Wokwi + ESP32

### 2.1 Código do ESP32
Use o código fornecido que publica temperatura no tópico MQTT: `iot/otavio`

**Broker MQTT:** `broker.emqx.io`
**Porta:** 1883
**Tópico:** `iot/otavio`

### 2.2 Adicionar Sensor DHT22 no Wokwi
1. No Wokwi, adicione um sensor **DHT22**
2. Conecte no pino **GPIO 15** do ESP32

### 2.3 Configurar WiFi Simulado
O Wokwi tem WiFi simulado chamado "Wokwi-GUEST" (sem senha)
Seu código ESP32 já está configurado para isso!

---

## 3️⃣ Configurar Dispositivos no Dashboard

### 3.1 Criar um Dispositivo
1. Acesse `index.html` (página inicial)
2. Clique em "Iniciar" para ir ao cadastro
3. Crie uma conta com email e senha
4. Faça login
5. No dashboard, adicione um novo dispositivo:
   - **Nome:** "Sensor Sala"
   - **Localização:** "Sala Principal"
   - **Temperatura Mín:** 15°C
   - **Temperatura Máx:** 30°C

---

## 4️⃣ Fluxo de Funcionamento

### Como os dados fluem:
```
ESP32 (Wokwi) 
    ↓
Lê sensor DHT22
    ↓
Publica via MQTT → broker.emqx.io:1883 (tópico: iot/otavio)
    ↓
Dashboard Web (mqtt.js)
    ↓
Inscreve e recebe mensagens
    ↓
Salva no Supabase (temperatura_readings)
    ↓
Atualiza UI com gráficos e alertas
```

---

## 5️⃣ Status dos Alertas

Baseado na temperatura recebida:

| Status | Condição | Cor |
|--------|----------|-----|
| **Normal** (🟢) | Temp < 75% do máximo | Verde |
| **Warning** (🟡) | Temp >= 75% do máximo | Amarelo |
| **Critical** (🔴) | Temp >= 100% do máximo | Vermelho |

**Exemplo:** Se máx = 30°C
- Normal: < 22.5°C
- Warning: 22.5°C a 30°C
- Critical: >= 30°C

---

## 6️⃣ Estrutura de Arquivos

```
seu-projeto/
├── index.html              # Página inicial
├── login.html              # Login
├── signup.html             # Cadastro
├── dashboard.html          # Dashboard com gráficos
├── supabase-schema.sql     # Schema do banco
└── SETUP_GUIDE.md          # Este arquivo
```

---

## 7️⃣ Servir os Arquivos

### Opção 1: Python (Recomendado)
```bash
python -m http.server 8000
```
Acesse: `http://localhost:8000`

### Opção 2: Node.js
```bash
npx http-server
```

### Opção 3: VS Code Live Server
1. Instale a extensão "Live Server"
2. Clique direito em qualquer HTML
3. Selecione "Open with Live Server"

---

## 8️⃣ Testar o Sistema

### Teste Passo a Passo:

1. **Inicie o Wokwi:**
   - Execute o código ESP32
   - Veja no serial monitor: "Temperatura publicada: XX.XX"

2. **Acesse o Dashboard:**
   - Abra o browser em `http://localhost:8000`
   - Faça login com suas credenciais

3. **Monitore em Tempo Real:**
   - As temperaturas devem aparecer a cada 3 segundos
   - Gráficos são atualizados automaticamente
   - Alertas aparecem quando temp > 75% do máximo

4. **Verifique o Supabase:**
   - Vá para **Table Editor**
   - Veja os dados em `temperature_readings`
   - Verifique `alerts` para notificações

---

## 9️⃣ Solução de Problemas

### Problema: "MQTT não conecta"
- ✅ Verifique se o broker está acessível: `broker.emqx.io`
- ✅ Verifique conexão de internet
- ✅ Abra console (F12) e procure por erros

### Problema: "Supabase retorna erro 401"
- ✅ Confirme as credenciais (URL e Chave)
- ✅ Verifique se o RLS está configurado corretamente

### Problema: "Sensor DHT22 não mostra dados"
- ✅ Verifique se está conectado no GPIO 15
- ✅ Reinicie a simulação do Wokwi

### Problema: "Gráficos não carregam"
- ✅ Abra console (F12) e veja erros
- ✅ Verifique se existem dados em `temperature_readings`

---

## 🔟 Monitoramento

### Visualizar Dados em Tempo Real

**Dashboard Wokwi:**
```
Serial Monitor → Mostra cada temperatura publicada
```

**Dashboard Web:**
```
Atualizações automáticas a cada mensagem MQTT
Gráficos mostram últimas 20 leituras
Alertas aparecem automaticamente
```

**Supabase:**
```
Table Editor → temperature_readings (histórico completo)
Table Editor → alerts (todos os alertas gerados)
```

---

## 📚 Referências Úteis

- **Supabase Docs:** https://supabase.com/docs
- **MQTT.js:** https://github.com/mqttjs/MQTT.js
- **EMQX Broker:** https://www.emqx.io/
- **DHT Sensor:** https://docs.wokwi.com/parts/wokwi-dht22
- **Wokwi Docs:** https://docs.wokwi.com/

---

## ✨ Dicas Extras

1. **Personalizar Tópico MQTT:**
   Edite em `dashboard.html`:
   ```javascript
   const MQTT_TOPICS = {
     temperature: 'seu/topico/aqui'
   };
   ```

2. **Mudar Cores do Dashboard:**
   Edite as cores CSS em cada arquivo:
   ```css
   --primary: #00d4ff;      /* Cyan */
   --success: #00ff88;      /* Verde */
   --warning: #ffcc00;      /* Amarelo */
   --danger: #ff4444;       /* Vermelho */
   ```

3. **Aumentar/Diminuir Frequência MQTT:**
   No código ESP32, altere:
   ```cpp
   delay(3000);  // Atualmente: a cada 3 segundos
   ```

---

**Sistema pronto! 🎉 Bom monitoramento!**
