listen_port = 10_943

describe port(listen_port) do
  it { should be_listening }
end
