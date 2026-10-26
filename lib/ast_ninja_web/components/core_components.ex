defmodule AstNinjaWeb.CoreComponents do
  @moduledoc """
  The handful of UI components the AST explorer uses.
  """
  use Phoenix.Component
  use Gettext, backend: AstNinjaWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.
  """
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div class="pointer-events-none fixed right-4 bottom-4 z-50 flex flex-col gap-2">
      <.flash :for={kind <- [:info, :error]} kind={kind} flash={@flash} />
    </div>
    """
  end

  attr :kind, :atom, values: [:info, :error]
  attr :flash, :map, required: true

  defp flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={"flash-#{@kind}"}
      role="alert"
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.hide(to: "#flash-#{@kind}")}
      class={[
        "pointer-events-auto cursor-pointer rounded-lg px-4 py-3 text-sm shadow-lg ring-1",
        @kind == :info && "bg-sky-950 text-sky-100 ring-sky-800",
        @kind == :error && "bg-rose-950 text-rose-100 ring-rose-800"
      ]}
    >
      {msg}
    </div>
    """
  end

  @doc """
  A small on/off switch bound to a form field name.
  """
  attr :name, :string, required: true
  attr :checked, :boolean, default: false
  attr :label, :string, required: true

  def toggle(assigns) do
    ~H"""
    <label class="group inline-flex cursor-pointer items-center gap-2 text-xs text-ink-muted select-none">
      <input type="hidden" name={@name} value="false" />
      <input type="checkbox" name={@name} value="true" checked={@checked} class="peer sr-only" />
      <span class="relative h-4 w-7 rounded-full bg-line transition peer-checked:bg-accent peer-focus-visible:ring-2 peer-focus-visible:ring-accent/50 after:absolute after:top-0.5 after:left-0.5 after:size-3 after:rounded-full after:bg-white after:transition peer-checked:after:translate-x-3">
      </span>
      <span class="group-hover:text-ink">{@label}</span>
    </label>
    """
  end

  @doc """
  Inline SVG icons (no icon font, no extra assets).
  """
  attr :name, :string, required: true
  attr :class, :string, default: "size-4"

  def icon(%{name: "github"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
      <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
    </svg>
    """
  end

  def icon(%{name: "slides"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
      <rect x="3" y="4" width="18" height="12" rx="1.5" /><path d="M12 16v4M8 20h8" />
    </svg>
    """
  end

  def icon(%{name: "help"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
      <circle cx="12" cy="12" r="9" /><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6v.6M12 17h.01" />
    </svg>
    """
  end

  def icon(%{name: "sparkles"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
      <path d="M12 3l1.8 4.7L18.5 9.5l-4.7 1.8L12 16l-1.8-4.7L5.5 9.5l4.7-1.8zM19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z" />
    </svg>
    """
  end

  def icon(%{name: "sun"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
      <circle cx="12" cy="12" r="4" /><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </svg>
    """
  end

  def icon(%{name: "moon"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
      <path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z" />
    </svg>
    """
  end

  def icon(%{name: "check"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" aria-hidden="true">
      <path d="M5 12.5l4.5 4.5L19 7.5" />
    </svg>
    """
  end

  def icon(%{name: "x"} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
      <path d="M6 6l12 12M18 6L6 18" />
    </svg>
    """
  end
end
