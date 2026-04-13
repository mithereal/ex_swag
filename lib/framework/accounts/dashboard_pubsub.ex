defmodule Framework.DashboardPubSub do
  @topic "dashboard:updates"

  def topic(user_id), do: "#{@topic}:#{user_id}"

  def broadcast(user_id, msg) do
    Phoenix.PubSub.broadcast(
      FrameworkWeb.PubSub,
      topic(user_id),
      msg
    )
  end
end