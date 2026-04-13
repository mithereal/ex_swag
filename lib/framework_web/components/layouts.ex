defmodule FrameworkWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FrameworkWeb, :html

  alias PhoenixKit.Users.Auth.Scope

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
        </a>
      </div>
     <div class="flex-none">
    <ul class="flex flex-row px-1 space-x-4 items-center">
    <!-- Your existing navigation items -->

    <%= if assigns[:phoenix_kit_current_scope] && Scope.authenticated?(assigns.phoenix_kit_current_scope) do %>
      <!-- Logged in: Show user info and actions -->
      <li class="hidden sm:flex items-center text-sm text-base-content/70">
        <.icon name="hero-user-circle" class="size-4 mr-1" />
        <%= Scope.user_email(assigns.phoenix_kit_current_scope) %>
      </li>
      <li>
        <.link href={PhoenixKit.Utils.Routes.path("/dashboard/settings")} class="btn btn-ghost btn-sm">
          <.icon name="hero-user" class="size-4" />
          <span class="hidden sm:inline ml-1">Account</span>
        </.link>
      </li>
      <li>
        <.link href={PhoenixKit.Utils.Routes.path("/users/log-out")} method="delete" class="btn btn-ghost btn-sm">
          <.icon name="hero-arrow-right-on-rectangle" class="size-4" />
          <span class="hidden sm:inline ml-1">Log out</span>
        </.link>
      </li>
    <% else %>
      <!-- Logged out: Show login/signup options -->
      <li>
        <.link href={PhoenixKit.Utils.Routes.path("/users/log-in")} class="btn btn-ghost btn-sm">
          <.icon name="hero-arrow-left-on-rectangle" class="size-4" />
          <span class="hidden sm:inline ml-1">Log in</span>
        </.link>
      </li>
      <li>
        <.link href={PhoenixKit.Utils.Routes.path("/users/register")} class="btn btn-primary btn-sm">
          <.icon name="hero-user-plus" class="size-4" />
          <span class="hidden sm:inline ml-1">Sign up</span>
        </.link>
      </li>
    <% end %>

    <.theme_toggle />
    </ul>
    </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
        {render_slot(@inner_block)}

    </main>

    <!-- Footer -->
    <footer class="py-10 text-center text-gray-500">
    © 2026 PrintFlow ERP. All rights reserved.
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
