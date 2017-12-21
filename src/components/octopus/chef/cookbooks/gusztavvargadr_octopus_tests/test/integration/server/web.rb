listen_port = 80

describe port(listen_port) do
  it { should be_listening }
end
