default['scp_develop']['debugger'] = {
  'chocolatey_packages_options' => {
    'visualstudio2017-remotetools' => {
      'elevated' => true,
    },
  },
  # https://docs.microsoft.com/en-us/visualstudio/debugger/remote-debugger-port-assignments?view=vs-2017#the-remote-debugger-port-on-64-bit-operating-systems
  'port_x64' => '4022', # 4022 default port for x64
  'port_x86' => '4023', # 4022+1 default port for x86 if we are running x64 version of remote debugger
  'msvsmon_path' => 'C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64', # Path to VS 2017 Remote Tools
}
