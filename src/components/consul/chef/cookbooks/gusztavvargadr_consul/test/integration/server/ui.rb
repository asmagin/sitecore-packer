listen_port = 8500

describe port(listen_port) do
  it { should be_listening }
end
