listen_port = 1433

describe port(listen_port) do
  it { should be_listening }
end
