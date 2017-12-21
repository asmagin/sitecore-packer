default['gusztavvargadr_vs']['2017_professional'] = {
  'native_packages' => {
    'Visual Studio 2017 Professional' => {
      'source' => 'https://download.microsoft.com/download/D/B/A/DBAB8920-72B8-4EBA-B92C-0EF2D83B0139/vs_Professional.exe',
      'install' => [
        '--installPath ""C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional""',
        '--add Microsoft.VisualStudio.Workload.CoreEditor',
        '--add Microsoft.VisualStudio.Workload.ManagedDesktop',
        '--add Microsoft.VisualStudio.Workload.NetWeb',
        '--add Microsoft.VisualStudio.Workload.Data',
        '--add Microsoft.VisualStudio.Workload.Azure',
        '--add Microsoft.VisualStudio.Workload.NetCoreTools',
        '--add Microsoft.VisualStudio.Component.TestTools.Core',
        '--add Microsoft.Net.Component.3.5.DeveloperTools',
        '--add Component.GitHub.VisualStudio',
        '--includeRecommended',
        '--includeOptional',
        '--quiet --norestart',
      ],
      'elevated' => true,
    },
  },
}
