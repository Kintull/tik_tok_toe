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
  def update_state(params) do
    GenServer.call(__MODULE__, {:update_state, params})
  end

  def add_player(name) do
    GenServer.call(__MODULE__, {:add_player, name})
  end

  def make_turn(player, index) do
    GenServer.call(__MODULE__, {:make_turn, player, index})
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

  def get_current_player() do
    GenServer.call(__MODULE__, :get_current_player)
  end


  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end

  def get_board() do
    GenServer.call(__MODULE__, :get_board)
  end

  def get_winner() do
    GenServer.call(__MODULE__, :get_winner)
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

  def handle_call({:make_turn, player, index}, _from, state) do
    with {:running, true} <- {:running, state.running},
         {:is_current_player, true} <- {:is_current_player, is_current_player(player, state)},
         new_state <- make_turn(player, index, state),
         %{winner: nil} <- new_state do
      {:reply, :ok, new_state}
    else
      %{winner: player} -> {:reply, {:ok, {:winner, player}}, state}
      {:error, :space_already_occupied} -> {:reply, {:error, :space_already_occupied}, state}
      {:running, false} -> {:reply, {:error, :battle_not_running}, state}
      {:is_current_player, false} -> {:reply, {:error, :not_current_player}, state}
    end
  end

  def handle_call(:make_running, _from, state) do
    with {:x_assigned, true} <- {:x_assigned, state.player_x != nil},
         {:o_assigned, true} <- {:o_assigned, state.player_o != nil},
         {:running, false} <- {:running, state.running} do
      {:reply, :ok, %{state | running: true, current_player: :player_x}}
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

  def handle_call(:get_board, _from, state) do
    {:reply, state.board, state}
  end

  def handle_call(:get_current_player, _from, state) do
    {:reply, state.current_player, state}
  end

  def handle_call(:is_running, _from, state) do
    {:reply, state.running == true, state}
  end

  def handle_call(:is_full, _from, state) do
    {:reply, is_full(state), state}
  end

  def handle_call(:get_winner, _from, state) do
    {:reply, state.winner, state}
  end

  def handle_call({:update_state, params}, _from, state) do
    {:reply, :ok, Map.merge(state, params)}
  end


  def handle_call({:is_current_player, name}, _from, state) do
    case state do
      %{current_player: :player_x, player_x: ^name} ->
        {:reply, {true, :player_x}, state}
      %{current_player: :player_o, player_o: ^name} ->
        {:reply, {true, :player_o}, state}
      _ ->
        {:reply, false, state}
    end
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

  defp is_current_player(player, %{current_player: player}), do: true
  defp is_current_player(_, _), do: false

  defp make_turn(player, index, state) do
    mark = if player == :player_x, do: "x", else: "o"
    case RoomLogic.user_action(mark, index, state.board) do
      {:ok, updated_board} ->
        case RoomLogic.has_winner?(updated_board) do
          {true, "x"} ->
            %{state | board: updated_board, winner: :player_x, current_player: nil}
          {true, "o"} ->
            %{state | board: updated_board, winner: :player_o, current_player: nil}
          false ->
            %{state | board: updated_board, current_player: next_player(state.current_player)}
        end
      {:error, :space_already_occupied} ->
        {:error, :space_already_occupied}
    end
  end

  defp is_full(%{player_o: nil, player_x: _}), do: false
  defp is_full(%{player_o: _, player_x: nil}), do: false
  defp is_full(%{player_o: _, player_x: _}), do: true

  defp initial_state() do
    %{
      player_x: nil,
      player_o: nil,
      running: false,
      current_player: nil,
      board: RoomLogic.initial_board(),
      winner: nil
    }
  end

  defp next_player(:player_x), do: :player_o
  defp next_player(:player_o), do: :player_x
end
