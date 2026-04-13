defmodule Framework.Plugin do
  @callback widgets() :: [map()]
  @callback enabled?(map()) :: boolean()
end