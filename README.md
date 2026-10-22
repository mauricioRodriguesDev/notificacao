# 📧 Microsserviço de Notificação por E-mail (API Notificação)

Uma API RESTful desenvolvida com **Java 17** e **Spring Boot 3**, responsável pelo envio de notificações por e-mail aos usuários quando suas tarefas estão agendadas. Utiliza **Spring Mail** para envio via SMTP (Gmail) e **Thymeleaf** para renderização de templates HTML estilizados. Faz parte de uma **arquitetura de microsserviços** junto com os projetos [usuario](https://github.com/mauricioRodriguesDev/usuario) e [agendador-tarefas](https://github.com/mauricioRodriguesDev/agendador-tarefas).

---

## 🚀 Tecnologias Utilizadas

| Categoria | Tecnologia |
| :--- | :--- |
| **Linguagem** | Java 17 |
| **Framework** | Spring Boot 3.5.11 |
| **Envio de E-mail** | Spring Boot Starter Mail (JavaMailSender / SMTP) |
| **Template de E-mail** | Thymeleaf (HTML renderizado no servidor) |
| **Servidor SMTP** | Gmail (`smtp.gmail.com`, porta 587 com STARTTLS) |
| **Produtividade** | Lombok |
| **Build Tool** | Gradle (com Wrapper `gradlew`) |
| **CI/CD** | GitHub Actions (Workflow de build com Gradle) |

---

## 📌 Funcionalidades

- **Envio de E-mail de Notificação:** Recebe os dados de uma tarefa agendada e envia um e-mail formatado ao usuário responsável.
- **Template HTML Estilizado:** E-mails são gerados dinamicamente com Thymeleaf, contendo nome da tarefa, data do evento e descrição.
- **Integração com SMTP Gmail:** Envio seguro via TLS com autenticação.
- **Tratamento de Exceções:** Exceção customizada `EmailException` para erros de envio.

---

## 🏛️ Arquitetura Geral — Ecossistema de Microsserviços

```text
┌──────────────┐         ┌────────────────────┐         ┌──────────────────┐
│              │  Auth   │                    │  HTTP   │                  │
│   Usuário    │◀───────▶│  Agendador-Tarefas │────────▶│   Notificação    │
│   API        │  Feign  │       API          │  POST   │      API         │
│              │         │                    │ /email  │                  │
│  porta 8080  │         │    porta 8081      │         │   porta 8082     │
│  PostgreSQL  │         │    MongoDB         │         │   SMTP Gmail     │
└──────────────┘         └────────────────────┘         └──────────────────┘
                                                               │
                                                               ▼
                                                        ┌──────────────┐
                                                        │  📧 E-mail   │
                                                        │  do Usuário  │
                                                        └──────────────┘
```

| Microsserviço | Porta | Banco / Serviço | Responsabilidade |
| :--- | :---: | :--- | :--- |
| **Usuário API** | `8080` | PostgreSQL | Cadastro, autenticação e gestão de usuários |
| **Agendador-Tarefas** | `8081` | MongoDB | Criação e gerenciamento de tarefas agendadas |
| **Notificação** | `8082` | SMTP Gmail | Envio de e-mails de notificação (este projeto) |

---

## 📊 Modelo de Dados

### DTO `TarefasDTO` (recebido via requisição)

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | `String` | Identificador da tarefa |
| `nomeTarefa` | `String` | Nome/título da tarefa |
| `descricao` | `String` | Descrição detalhada |
| `emailUsuario` | `String` | E-mail do destinatário da notificação |
| `dataCriacao` | `LocalDateTime` | Data de criação da tarefa (formato: `dd-MM-yyyy HH:mm:ss`) |
| `dataEvento` | `LocalDateTime` | Data do evento agendado (formato: `dd-MM-yyyy HH:mm:ss`) |
| `dataAlteracao` | `LocalDateTime` | Data da última alteração (formato: `dd-MM-yyyy HH:mm:ss`) |
| `statusNotificacaoEnum` | `Enum` | Status: `PENDENTE`, `NOTIFICADO` ou `CANCELADO` |

---

## 📋 Pré-requisitos

- [JDK 17+](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
- [Git](https://git-scm.com/)
- Uma **conta Gmail** com [Senha de App](https://support.google.com/accounts/answer/185833?hl=pt-BR) gerada (necessário para envio SMTP)

---

## ⚙️ Configuração

As configurações estão no arquivo `src/main/resources/application.yml`:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${GMAIL_USERNAME}
    password: ${GMAIL_APP_PASSWORD}
    protocol: smtp
    properties:
      mail:
        smtp:
          socketFactory:
            port: 465
            class: javax.net.ssl.SSLSocketFactory
            fallback: false
          auth: true
          starttls:
            enable: true
          connectiontimeout: 5000
          timeout: 3000
          writetimeout: 5000

  thymeleafe:
    enable: true

envio:
  email:
    remetente: ${GMAIL_USERNAME}
    nomeRemetente: 'Javanauta'

server:
  port: ${SERVER_PORT:8082}
```

### 🔒 Variáveis de Ambiente Recomendadas

Para proteger suas credenciais e impedir commits acidentais de senhas no Git, defina as variáveis de ambiente antes de inicializar a aplicação:

- **Linux / macOS:**
  ```bash
  export GMAIL_USERNAME="seu-email@gmail.com"
  export GMAIL_APP_PASSWORD="sua-senha-de-app-16-digitos"
  ```

- **Windows (PowerShell):**
  ```powershell
  $env:GMAIL_USERNAME="seu-email@gmail.com"
  $env:GMAIL_APP_PASSWORD="sua-senha-de-app-16-digitos"
  ```

### ⚠️ Configuração obrigatória antes de executar

| Campo | Onde configurar | O que colocar |
| :--- | :--- | :--- |
| `GMAIL_USERNAME` | Variável de ambiente | Seu e-mail Gmail (ex: `seuemail@gmail.com`) |
| `GMAIL_APP_PASSWORD` | Variável de ambiente | Senha de App gerada no Google ([como gerar](https://support.google.com/accounts/answer/185833?hl=pt-BR)) |

> 🔒 **Segurança:** Nunca comite senhas reais no repositório. Considere usar variáveis de ambiente:
> ```yaml
> spring:
>   mail:
>     username: ${GMAIL_USERNAME}
>     password: ${GMAIL_APP_PASSWORD}
> ```

---

## 🛠️ Como Executar

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/mauricioRodriguesDev/notificacao.git
   cd notificacao
   ```

2. **Configure o `application.yml`** com suas credenciais Gmail (veja seção acima).

3. **Compile e execute:**
    - **Linux / macOS:**
      ```bash
      ./gradlew bootRun
      ```
    - **Windows:**
      ```powershell
      .\gradlew.bat bootRun
      ```

A aplicação estará acessível em: `http://localhost:8082`

---

## 🛣️ Endpoint da API

### Enviar E-mail de Notificação

**`POST /email`**

Recebe os dados de uma tarefa e envia um e-mail formatado ao usuário.

**Payload:**

```json
{
  "id": "671234abc567def890123456",
  "nomeTarefa": "Reunião de Sprint",
  "descricao": "Reunião de planejamento da sprint 15 na sala de conferências",
  "emailUsuario": "joao@email.com",
  "dataCriacao": "22-10-2026 15:00:00",
  "dataEvento": "25-10-2026 14:00:00",
  "dataAlteracao": null,
  "statusNotificacaoEnum": "PENDENTE"
}
```

**Resposta:** `200 OK` (sem body)

---

## 📨 Template do E-mail

O e-mail é renderizado com **Thymeleaf** usando o template [`notificacao.html`](src/main/resources/templates/notificacao.html). O resultado é um e-mail HTML estilizado com:

```text
┌─────────────────────────────────────────────────────┐
│                                                     │
│            Notificação de Tarefa                    │
│                                                     │
│  Aviso: Sua tarefa [Nome da Tarefa] está agendada   │
│  para hoje às [Horário].                            │
│                                                     │
│  Confira sua descrição:                             │
│  [Descrição da Tarefa]                              │
│                                                     │
│  Obrigado por usar nosso sistema de tarefas.        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Variáveis injetadas no template:

| Variável | Campo do DTO | Exibição |
| :--- | :--- | :--- |
| `${nomeTarefa}` | `nomeTarefa` | Nome da tarefa em destaque (vermelho/negrito) |
| `${dataEvento}` | `dataEvento` | Horário do evento em destaque (vermelho/negrito) |
| `${descricao}` | `descricao` | Texto da descrição da tarefa |

---

## 🔐 Recomendações de Segurança e Isolamento

> ⚠️ **Atenção:** Este microsserviço **não possui camada de autenticação pública (Spring Security ou JWT)**. Seu endpoint `POST /email` é projetado estritamente para consumo interno por outros serviços.

### 🛡️ Boas práticas para mitigar riscos de segurança:
1. **Isolamento de Rede:** O serviço **não deve ter sua porta 8082 exposta à internet**. Ele deve rodar em uma sub-rede privada ou rede interna (ex: Docker network interna, VPC da nuvem) acessível unicamente pelos serviços autorizados.
2. **Proteção contra Abuso de SMTP:** Como não há login no endpoint, a exposição direta permitiria envio irrestrito de e-mails em massa através da sua conta.
3. **Evolução Arquitetural:** Para ambientes de produção, recomenda-se substituir a chamada HTTP síncrona por consumo assíncrono via mensageria (RabbitMQ ou Apache Kafka), eliminando totalmente a necessidade de expor portas HTTP.

---

## 🧪 Testes

```bash
# Linux / macOS
./gradlew test

# Windows
.\gradlew.bat test
```

---

## 📂 Estrutura Completa de Arquivos

```text
notificacao/
├── .github/
│   └── workflows/
│       └── gradle.yml                                  # CI/CD com GitHub Actions
├── gradle/
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── src/
│   └── main/
│       ├── java/com/javanauta/notificacao/
│       │   ├── NotificacaoApplication.java             # Classe principal Spring Boot
│       │   ├── business/
│       │   │   ├── dto/
│       │   │   │   └── TarefasDTO.java                 # DTO de Tarefas (com @JsonFormat)
│       │   │   ├── enums/
│       │   │   │   └── StatusNotificacaoEnum.java      # PENDENTE, NOTIFICADO, CANCELADO
│       │   │   └── service/
│       │   │       └── EmailService.java               # Lógica de envio de e-mail (JavaMailSender + Thymeleaf)
│       │   ├── controller/
│       │   │   └── EmailController.java                # REST Controller (POST /email)
│       │   └── infrastructure/
│       │       └── exceptions/
│       │           └── EmailExeception.java            # Exceção customizada para erros de envio
│       └── resources/
│           ├── application.yml                         # Configurações SMTP, Thymeleaf e porta
│           └── templates/
│               └── notificacao.html                    # Template HTML do e-mail (Thymeleaf)
├── .gitattributes
├── .gitignore
├── build.gradle                                        # Dependências e plugins Gradle
├── gradlew                                             # Gradle Wrapper (Linux/macOS)
├── gradlew.bat                                         # Gradle Wrapper (Windows)
└── settings.gradle                                     # Configurações do projeto Gradle
```

---

## 🔗 Projetos Relacionados

| Microsserviço | Porta | Descrição | Repositório |
| :--- | :---: | :--- | :--- |
| **Usuário API** | `8080` | Cadastro de usuários e autenticação JWT | [mauricioRodriguesDev/usuario](https://github.com/mauricioRodriguesDev/usuario) |
| **Agendador de Tarefas** | `8081` | Agendamento e gestão de tarefas | [mauricioRodriguesDev/agendador-tarefas](https://github.com/mauricioRodriguesDev/agendador-tarefas) |
| **Notificação** | `8082` | Envio de e-mails de notificação (este projeto) | [mauricioRodriguesDev/notificacao](https://github.com/mauricioRodriguesDev/notificacao) |

---

## 📄 Licença

Este projeto é de uso livre para fins de estudo e desenvolvimento.

---

## 👨‍💻 Autor

Desenvolvido por [mauricioRodriguesDev](https://github.com/mauricioRodriguesDev).
