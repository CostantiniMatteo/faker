defmodule Faker.Address do
  defdelegate postcode, to: Faker.Address, as: :zip_code
  defdelegate zip, to: Faker.Address, as: :zip_code

  data_path = Path.expand(Path.join(__DIR__, "../../priv/address.json"))
  json = File.read!(data_path) |> Poison.Parser.parse!
  Enum.each json, fn(el) ->
    {lang, data} = el
    Enum.each data, fn
      {"values", values} ->
        Enum.each values, fn({fun, list}) ->
          def unquote(String.to_atom(fun))() do
            unquote(String.to_atom("get_#{fun}"))(Faker.locale, :crypto.rand_uniform(0, unquote(String.to_atom("#{fun}_count"))(Faker.locale)))
          end
          defp unquote(String.to_atom("#{fun}_count"))(unquote(String.to_atom(lang))) do
            unquote(Enum.count(list))
          end
          Enum.with_index(list) |> Enum.each fn({el, index}) ->
            defp unquote(String.to_atom("get_#{fun}"))(unquote(String.to_atom(lang)), unquote(index)) do
              unquote(el)
            end
          end
        end
      {"formats", values} ->
        Enum.each values, fn({fun, list}) ->
          def unquote(String.to_atom(fun))() do
            unquote(String.to_atom("format_#{fun}"))(Faker.locale, :crypto.rand_uniform(0, unquote(String.to_atom("#{fun}_count"))(Faker.locale)))
          end
          Enum.with_index(list) |> Enum.each fn({el, index}) ->
            defp unquote(String.to_atom("format_#{fun}"))(unquote(String.to_atom(lang)), unquote(index)) do
              Faker.format(unquote(el))
            end
          end
          defp unquote(String.to_atom("#{fun}_count"))(unquote(String.to_atom(lang))) do
            unquote(Enum.count(list))
          end
        end
      {"functions", values} ->
        Enum.each values, fn({fun, list}) ->
          def unquote(String.to_atom(fun))() do
            unquote(String.to_atom(fun))(Faker.locale, :crypto.rand_uniform(0, unquote(String.to_atom("#{fun}_count"))(Faker.locale)))
          end
          Enum.with_index(list) |> Enum.each fn({el, index}) ->
            defp unquote(String.to_atom(fun))(unquote(String.to_atom(lang)), unquote(index)) do
              unquote(Code.string_to_quoted!('"#{el}"'))
            end
          end
          defp unquote(String.to_atom("#{fun}_count"))(unquote(String.to_atom(lang))) do
            unquote(Enum.count(list))
          end
        end
    end
  end

  def latitude do
    :random.seed(:erlang.now)
    ((:random.uniform * 180) - 90)
  end

  def longitude do
    :random.seed(:erlang.now)
    ((:random.uniform * 360) - 180)
  end

  def street_address(true), do: street_address <> " " <> secondary_address
  def street_address(_), do: street_address
end