listen_port = 10_933

describe port(listen_port) do
  it { should be_listening }
end
