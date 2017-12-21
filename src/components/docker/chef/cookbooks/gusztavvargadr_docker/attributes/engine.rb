default['gusztavvargadr_docker']['engine'] = {
  'native_packages' => {
    'Docker for Windows (Edge)' => {
      'source' => 'https://download.docker.com/win/edge/Docker%20for%20Windows%20Installer.exe',
      'install' => [
        'install',
        '--quiet',
      ],
    },
  },
}
