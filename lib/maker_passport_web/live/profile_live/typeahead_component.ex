defmodule MakerPassportWeb.ProfileLive.TypeaheadComponent do
  use MakerPassportWeb, :live_component
  use Phoenix.Component

  import MakerPassportWeb.CoreComponents

  attr :id, :string, default: "typeahead"
  attr :name, :string, default: "search-field"
  attr :value, :string, default: ""
  attr :label, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global
  attr :on_select, :any, default: nil
  attr :on_search, :any, required: true
  attr :disabled, :boolean, default: false

  def typeahead(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      name={@name}
      value={@value}
      label={@label}
      rest={@rest}
      class={@class}
      on_select={@on_select}
      on_search={@on_search}
      disabled={@disabled}
    />
    """
  end

  attr :id, :string
  attr :name, :string
  attr :value, :string
  attr :myself, :any
  attr :focused_option, :any
  attr :search_options, :list, default: []

  def dropdown_options(assigns) do
    ~H"""
    <div id={@id} class="absolute mt-1 z-10 bg-white rounded-lg shadow w-full dark:bg-gray-700">
      <ul
        data-focused-option={@focused_option}
        class="max-h-60 py-2 overflow-y-auto text-gray-700 dark:text-gray-200"
        role="listbox">
        <li
          :for={{{label, value}, idx} <- @search_options |> Enum.with_index(0)}
          id={"#{@id}-#{idx}"}
          class={[
            "flex items-center px-4 py-2",
            @focused_option == value && "bg-gray-100 dark:bg-gray-600 dark:text-white"
          ]}
          role="option"
          phx-hook="ComboboxOption"
          phx-click="select-option"
          phx-target={@myself}
          phx-value-option={value}
        >
          <span class="block truncate text-sm"><%= label %></span>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-1">
      <.label :if={@label} for={@id}><%= @label %></.label>
      <div class="relative" phx-click-away="hide-options" phx-target={@myself}>
        <input
          type="text"
          name={@name}
          id={@id}
          autocomplete="off"
          value={@value}
          class={[
            "block text-grey-700 focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500 phx-no-feedback:border-gray-300",
            "phx-no-feedback:focus:border-blue-500 phx-no-feedback:focus:ring-blue-500/5",
            "phx-no-feedback:dark:border-gray-600 phx-no-feedback:dark:focus:border-blue-500 phx-no-feedback:dark:focus:ring-blue-500/5",
            "#{@class}",
            @disabled && "bg-gray-200 cursor-not-allowed"
          ]}
          role="combobox"
          phx-keydown="set-focus"
          phx-target={@myself}
          phx-hook="Combobox"
          {@rest}
          disabled={@disabled}
        />

        <.dropdown_options
          :if={@options_visible}
          myself={@myself}
          id={"#{@id}-options"}
          focused_option={@focused_option}
          search_options={@search_options}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign_reset(socket)}
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def handle_event("filter-options", %{"search_phrase" => search_phrase}, socket) do
    search_options = socket.assigns.on_search.(search_phrase)

    {
      :noreply,
      socket
      |> assign(:search_options, search_options)
      |> assign(:search_phrase, search_phrase)
      |> assign(:options_visible, true)
    }
  end

  def handle_event("select-option", %{"option" => selected_value}, socket) do
    {label, value} = find_option_by(selected_value, socket)

    if value && socket.assigns.on_select do
      socket.assigns.on_select.({label, value})
    end

    {
      :noreply,
      socket
      |> assign_reset()
      |> push_event("set-input-value", %{id: socket.assigns.id, label: ""})
    }
  end

  def handle_event("set-focus-to", %{"value" => focused_option}, socket) do
    {:noreply, assign(socket, focused_option: focused_option)} # Send from JS when hovering the list
  end

  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    focused_option = assigns_prev_focus_option(socket.assigns)
    {:noreply, assign(socket, focused_option: focused_option)}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    focused_option = assigns_next_focus_option(socket.assigns)
    {:noreply, assign(socket, focused_option: focused_option)}
  end

  def handle_event("set-focus", %{"key" => key}, socket) when key in ~w(Escape Tab) do
    {:noreply, assign_reset(socket)}
  end

  # FALLBACK FOR NON RELATED KEY STROKES
  def handle_event("set-focus", _, socket), do: {:noreply, socket}

  def handle_event("hide-options", _params, socket) do
    {:noreply, assign_reset(socket)}
  end

  # Helper functions below

  defp find_option_by(selected_value, _socket) when selected_value in [nil, ""], do: {nil, nil}
  defp find_option_by(selected_value, %{assigns: %{search_options: search_options}}) do
    Enum.find(search_options, {nil, nil}, fn {_label, value} -> to_string(value) == to_string(selected_value) end)
  end

  defp assign_reset(socket) do
    socket
    |> assign(:focused_option, nil)
    |> assign(:search_options, [])
    |> assign(:options_visible, false)
  end

  defp assigns_next_focus_option(%{search_options: search_options, focused_option: focused_option}) do
    search_options
    |> Enum.map(fn {_, value} -> value end)
    |> next_option(focused_option)
  end

  defp assigns_prev_focus_option(%{search_options: search_options, focused_option: focused_option}) do
    assigns_next_focus_option(%{search_options: Enum.reverse(search_options), focused_option: focused_option})
  end

  # Base case: Empty list or target not found
  defp next_option([], _target), do: nil

  # Base case: Last item reached without finding the target
  # defp next_option([_last], _target), do: nil
  defp next_option([last], _target), do: last

  # Starting case: no current value
  defp next_option([first | _], nil), do: first

  # Match when the current item is the target
  defp next_option([current, next | _], current), do: next

  # Recursive call: Keep traversing the list
  defp next_option([_ | rest], target), do: next_option(rest, target)
end
