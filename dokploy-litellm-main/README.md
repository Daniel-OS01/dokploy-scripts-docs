# LiteLLM for Dokploy

LiteLLM Docker Compose prepared for using on Dokploy.

## Requirements

### PostgreSQL Service

You need to start a PostgreSQL service for database.

### Redis Servcie

You need to start a redis service for cache.

## Envioriments variables

```env

HASH=<>
PROXY_PORT=4000
PROXY_HOST=<>
NUM_WORKERS=8
LITELLM_MASTER_KEY=<>
LITELLM_SALT_KEY=<>
LITELLM_LOG="ERROR"
LITELLM_MODE="PRODUCTION"
DATABASE_URL=<>
REDIS_HOST=<>
REDIS_PASSWORD=<>
REDIS_USER=default
REDIS_PORT=6379
UI_USERNAME=<>
UI_PASSWORD=<>

SENTRY_DSN=<>
SENTRY_TRACES_SAMPLE_RATE=1.0
SENTRY_ENABLED=true
LANGFUSE_HOST=<>
LANGFUSE_PUBLIC_KEY=<>
LANGFUSE_SECRET_KEY=<>

# Providers API
OPENAI_API_KEY=<open_api_key>
GROQ_API_KEY=<>
CLOUDFLARE_API_KEY=<>
CLOUDFLARE_API_BASE=https://gateway.ai.cloudflare.com/v1/<account>/<aigateway>/workers-ai/v1
GITHUB_API_KEY=<>

```

## Config.yaml template

```yaml
model_list:
# OpenAI
  - model_name: dall-e-3 # alias for dall-e-3
    litellm_params:
      model: openai/dall-e-3
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: image_generation
      base_model: dall-e-3
  - model_name: openai-dall-e-3
    litellm_params:
      model: openai/dall-e-3
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: image_generation
      base_model: dall-e-3
  - model_name: openai-dall-e-2 # alias for dall-e-2
    litellm_params:
      model: openai/dall-e-2
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: image_generation
      base_model: dall-e-2
  - model_name: openai-dall-e-2
    litellm_params:
      model: openai/dall-e-2
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: image_generation
      base_model: dall-e-2
  - model_name: gpt-3.5-turbo
    litellm_params:
      model: openai/gpt-3.5-turbo   
      api_key: os.environ/OPENAI_API_KEY
  - model_name: gpt-3.5-turbo-instruct
    litellm_params:
      model: text-completion-openai/gpt-3.5-turbo-instruct
      api_key: os.environ/OPENAI_API_KEY
  - model_name: gpt-3.5-turbo-large
    litellm_params: 
      model: "gpt-3.5-turbo-1106"
      api_key: os.environ/OPENAI_API_KEY
      rpm: 480
      timeout: 300
      stream_timeout: 60
  - model_name: "davinci"
    litellm_params:
      model: "openai/davinci-002"
      api_key: os.environ/OPENAI_API_KEY

# Grog
  - model_name: "groq/*"
    litellm_params:
      model: "groq/*"
      api_key: os.environ/GROQ_API_KEY

# Cloudflare
  - model_name: "phi-2"
    litellm_params:
      model: "openai/@cf/microsoft/phi-2"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE
  - model_name: "starling-lm-7b"
    litellm_params:
      model: "openai/@hf/nexusflow/starling-lm-7b-beta"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE
    model_info:
      supports_vision: True
  - model_name: "mistral-7b"
    litellm_params:
      model: "openai/@hf/mistral/mistral-7b-instruct-v0.2"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE
  - model_name: "cf/llama-3.2-11b"
    litellm_params:
      model: "openai/@cf/meta/llama-3.2-11b-vision-instruct"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE
    model_info:
      supports_vision: True
  - model_name: "llama-3.2-3b"
    litellm_params:
      model: "openai/@cf/meta/llama-3.2-3b-instruct"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE
      max_tokens: 4096
  - model_name: "llama-2-7b-chat-fp16"
    litellm_params:
      model: "openai/@cf/meta/llama-2-7b-chat-fp16"
      api_key: os.environ/CLOUDFLARE_API_KEY
      api_base: os.environ/CLOUDFLARE_API_BASE    

# Github
  - model_name: "llama3-8b"
    litellm_params:
      model: "github/Meta-Llama-3-8B-Instruct"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "llama3.2-11b"
    litellm_params:
      model: "github/Llama-3.2-11B-Vision-Instruct"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
    model_info:
      supports_vision: True
  - model_name: "mistral-large"
    litellm_params:
      model: "github/Mistral-large-2407"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "mistral-nemo"
    litellm_params:
      model: "github/Mistral-Nemo"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "cohere-plus"
    litellm_params:
      model: "github/Cohere-command-r-plus-08-2024"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "phi-3"
    litellm_params:
      model: "github/Phi-3-medium-128k-instruct"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "phi-3.5-MoE"
    litellm_params:
      model: "github/Phi-3.5-MoE-instruct"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "Phi-4"
    litellm_params:
      model: "github/Phi-4"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "gpt-4o"
    litellm_params:
      model: "github/gpt-4o"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
    model_info:
      supports_vision: True
  - model_name: "gpt-4o-mini"
    litellm_params:
      model: "github/gpt-4o-mini"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
    model_info:
      supports_vision: True
  - model_name: "jamba"
    litellm_params:
      model: "github/AI21-Jamba-1.5-Large"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 10
  - model_name: "text-embedding-3-large"
    litellm_params:
      model: "github/text-embedding-3-large"
      api_key: os.environ/GITHUB_API_KEY
      rpm: 15
    model_info:
      mode: embedding

litellm_settings:
  set_verbose: False  # Uncomment this if you want to see verbose logs; not recommended in production
  drop_params: True
  # max_budget: 100 
  # budget_duration: 30d
  num_retries: 5
  request_timeout: 120
  telemetry: True
  set_verbose: True
  cache: True
  #callbacks: ["langfuse"]
  redact_user_api_key_info: true
  input_callback: ["langfuse"]
  failure_callback: ["sentry"]
  success_callback: ["langfuse"]
#  context_window_fallbacks: [{"llama3-8b": ["llama3-8b-8192"]}]

router_settings:
  routing_strategy: usage-based-routing-v2 
  redis_host: os.environ/REDIS_HOST
  redis_password: os.environ/REDIS_PASSWORD
  redis_port: os.environ/REDIS_PORT
  timeout: 120
#  enable_pre_call_checks: true
#  model_group_alias: {"my-special-fake-model-alias-name": "fake-openai-endpoint-3"} 

general_settings: 
  master_key: os.environ/LITELLM_MASTER_KEY # [OPTIONAL] Use to enforce auth on proxy. See - https://docs.litellm.ai/docs/proxy/virtual_keys
  store_model_in_db: False
  disable_spend_logs: False
  #proxy_budget_rescheduler_min_time: 60
  #proxy_budget_rescheduler_max_time: 65
  proxy_batch_write_at: 60
  database_connection_pool_limit: 20
  database_connection_timeout: 45
  database_url: os.environ/DATABASE_URL # [OPTIONAL] use for token-based auth to proxy
```