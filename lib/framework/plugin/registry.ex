defmodule Framework.Plugin.Registry do
  alias Framework.Plugin

  def plugins do
    :code.all_loaded()
    |> Enum.map(fn {mod, _} -> mod end)
    |> Enum.filter(&plugin?/1)
  end

  defp plugin?(mod) do
    function_exported?(mod, :widgets, 0)
  end

  def widgets(user) do
    plugins()
    |> Enum.filter(&safe_enabled?(&1, user))
    |> Enum.flat_map(&safe_widgets/1)
  end

  defp safe_widgets(mod) do
    try do
      mod.widgets()
    rescue
      _ -> []
    end
  end

  defp safe_enabled?(mod, user) do
    if function_exported?(mod, :enabled?, 1) do
      mod.enabled?(user)
    else
      true
    end
  end
end