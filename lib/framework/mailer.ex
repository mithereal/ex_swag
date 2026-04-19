defmodule Framework.Mailer do
  use Swoosh.Mailer, otp_app: :framework
  require Logger
end
