defmodule BitcoinNetwork.Protocol.TxIn do
  defstruct previous_output: nil,
            script_length: nil,
            signature_script: nil,
            sequence: nil
end
