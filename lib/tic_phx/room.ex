defmodule Room do
  @moduledoc """
  A GenServer template for a "singleton" process.
  """
  use GenServer

  # Initialization
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    running = Keyword.get(opts, :running, false)

    state = Map.merge(initial_state(), %{running: running})

    {:ok, state}
  end

  def make_running() do
    GenServer.call(__MODULE__, :make_running)
  end

  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  # API
  def add_player(name) do
    GenServer.call(__MODULE__, {:add_player, name})
  end

  def make_turn(name) do
    GenServer.call(__MODULE__, {:make_turn, name})
  end

  def is_running?() do
    GenServer.call(__MODULE__, :is_running)
  end

  def is_full?() do
    GenServer.call(__MODULE__, :is_full)
  end

  def is_current_player?(name) do
    GenServer.call(__MODULE__, {:is_current_player, name})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end

  # Callbacks

  def handle_call({:add_player, name}, _from, state) do
    with {:running, false} <- {:running, state.running},
         {:ok, new_state} <- assign_player(state, name) do
      {:reply, :ok, new_state}
    else
      {:error, :full} -> {:reply, {:error, :room_is_full}, state}
      {:running, true} -> {:reply, {:error, :battle_running}, state}
    end
  end

  def handle_call({:make_turn, name}, _from, state) do
    with {:running, true} <- {:running, state.running},
         {:is_current_player, true} <- {:is_current_player, is_current_player(name, state)},
         new_state <- make_turn(name, state) do
      {:reply, :ok, new_state}
    else
      {:running, false} -> {:reply, {:error, :battle_not_running}, state}
      {:is_current_player, false} -> {:reply, {:error, :not_current_player}, state}
    end
  end

  def handle_call(:make_running, _from, state) do
    with {:x_assigned, true} <- {:x_assigned, state.player_x != nil},
         {:o_assigned, true} <- {:o_assigned, state.player_o != nil},
         {:running, false} <- {:running, state.running} do
      {:reply, :ok, %{state | running: true, current_player: state.player_x}}
    else
      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, initial_state()}
  end

  def handle_call(:get_players, _from, state) do
    {:reply, Map.take(state, [:player_x, :player_o]), state}
  end

  def handle_call(:is_running, _from, state) do
    {:reply, state.running == true, state}
  end

  def handle_call(:is_full, _from, state) do
    {:reply, is_full(state), state}
  end

  def handle_call({:is_current_player, name}, _from, state) do
    {:reply, state.current_player == name, state}
  end

  def handle_info({:baz, [value]}, state) do
    state = %{state | baz: value}
    {:noreply, state}
  end

  defp assign_player(%{player_x: nil, player_o: nil} = state, name) do
    {:ok, %{state | player_x: name, player_o: nil}}
  end

  defp assign_player(%{player_x: nil, player_o: _} = state, name) do
    {:ok, %{state | player_x: name}}
  end

  defp assign_player(%{player_x: _, player_o: nil} = state, name) do
    {:ok, %{state | player_o: name}}
  end

  defp assign_player(%{player_x: _, player_o: _}, _name) do
    {:error, :full}
  end

  defp is_current_player(name, %{player_x: name, current_player: name}), do: true
  defp is_current_player(name, %{player_o: name, current_player: name}), do: true
  defp is_current_player(_, _), do: false

  defp make_turn(name, %{player_x: name, player_o: another_player, current_player: name} = state) do
    %{state | current_player: another_player}
  end

  defp make_turn(name, %{player_o: name, player_x: another_player, current_player: name} = state) do
    %{state | current_player: another_player}
  end

  defp is_full(%{player_o: nil, player_x: _}), do: false
  defp is_full(%{player_o: _, player_x: nil}), do: false
  defp is_full(%{player_o: _, player_x: _}), do: true

  defp initial_state() do
    %{
      player_x: nil,
      player_o: nil,
      running: false,
      current_player: nil
    }
  end
end
