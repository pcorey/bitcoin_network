# defmodule BitcoinNetwork.Protocol do
#   def reverse(binary) do
#     binary
#     |> :binary.decode_unsigned(:little)
#     |> :binary.encode_unsigned(:big)
#   end

#   def net_addr(time, services, ip, port) do
#     <<
#       time::32-little,
#       services::64-little,
#       :binary.decode_unsigned(ip)::128-big,
#       port::16-big
#     >>
#   end

#   def net_addr(services, ip, port) do
#     <<
#       services::64-little,
#       :binary.decode_unsigned(ip)::128-big,
#       port::16-big
#     >>
#   end

#   def var_int(int) when int < 0xFD, do: <<int::8-little>>
#   def var_int(int) when int < 0xFFFF, do: <<0xFD, int::16-little>>
#   def var_int(int) when int < 0xFFFFFFFF, do: <<0xFE, int::32-little>>
#   def var_int(int), do: <<0xFF, int::64-little>>

#   def var_str(""), do: <<0>>

#   def var_str(str) do
#     <<
#       var_int(String.length(str))::binary,
#       reverse(str)::binary
#     >>
#   end

#   def version(
#         version,
#         services,
#         timestamp,
#         recv_ip,
#         recv_port,
#         from_ip,
#         from_port,
#         nonce,
#         user_agent,
#         start_height
#       ) do
#     <<
#       version::32-little,
#       services::64-little,
#       timestamp::64-little,
#       net_addr(services, recv_ip, recv_port)::binary-big,
#       net_addr(services, from_ip, from_port)::binary-big,
#       nonce::64-little,
#       var_str(user_agent)::binary-big,
#       start_height::32-little
#     >>
#   end

#   def wrap_message(payload, command, magic \\ Application.get_env(:bitcoin_network, :magic)) do
#     checksum = checksum(payload)

#     padding = 8 * (12 - byte_size(command))

#     <<
#       magic::binary,
#       command::binary,
#       0::size(padding),
#       byte_size(payload)::32-little,
#       :binary.encode_unsigned(checksum)::binary,
#       payload::binary
#     >>
#   end

#   def message(command, args) do
#     payload = apply(BitcoinNetwork.Protocol, command, args)

#     <<
#       Application.get_env(:bitcoin_network, :magic)::binary,
#       String.pad_trailing(Atom.to_string(command), 12, <<0>>)::binary,
#       byte_size(payload)::32-little,
#       :binary.encode_unsigned(checksum(payload))::binary,
#       payload::binary
#     >>
#   end

#   def verify_checksum(<<
#         _magic::32,
#         _command::96,
#         size::32-little,
#         checksum::32,
#         payload::binary
#       >>) do
#     checksum(payload) == checksum && byte_size(payload) == size
#   end

#   def verify_checksum(_), do: false

#   def checksum(payload) do
#     <<checksum::32, _::binary>> =
#       payload
#       |> hash(:sha256)
#       |> hash(:sha256)

#     checksum
#   end

#   defp hash(data, algorithm), do: :crypto.hash(algorithm, data)
# end
