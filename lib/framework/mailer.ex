defmodule Framework.Mailer do
  use Swoosh.Mailer, otp_app: :framework, adapter: Resend.Swoosh.Adapter,
                     api_key: System.fetch_env!("RESEND_API_KEY")
  require Logger

end
