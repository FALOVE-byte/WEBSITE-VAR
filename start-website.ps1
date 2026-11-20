$ErrorActionPreference = "Stop"

function Convert-SecureStringToPlainText([System.Security.SecureString]$Value) {
  $pointer = [IntPtr]::Zero
  try {
    $pointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Value)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
  } finally {
    if ($pointer -ne [IntPtr]::Zero) {
      [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
  }
}

$username = Read-Host "Username admin (kosongkan untuk admin)"
if ([string]::IsNullOrWhiteSpace($username)) {
  $username = "admin"
}
if ($username.Contains(":") -or $username -match "\s") {
  throw "Username tidak boleh mengandung spasi atau titik dua."
}

do {
  $securePassword = Read-Host "Buat password admin (minimal 12 karakter)" -AsSecureString
  $password = Convert-SecureStringToPlainText $securePassword
  if ($password.Length -lt 12) {
    Write-Host "Password harus minimal 12 karakter." -ForegroundColor Yellow
  }
} while ($password.Length -lt 12)

$confirmPassword = Convert-SecureStringToPlainText (Read-Host "Ulangi password admin" -AsSecureString)
if ($password -cne $confirmPassword) {
  throw "Konfirmasi password tidak cocok. Jalankan ulang server."
}
$confirmPassword = $null

$root = [System.IO.Path]::GetFullPath($PSScriptRoot)
$adminFile = [System.IO.Path]::GetFullPath((Join-Path $root "admin.html"))
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 8765)
$listener.Start()

Write-Host "TEAM VAR aktif di http://127.0.0.1:8765/"
Write-Host "Buka panel admin di http://127.0.0.1:8765/admin.html"
Write-Host "Login admin: username '$username' dan password yang baru dibuat."
Write-Host "Tekan Ctrl+C untuk menghentikan server."

try {
  while ($listener.Server.IsBound) {
    $client = $listener.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      if ($null -eq $requestLine) {
        continue
      }

      $authorization = ""
      while ($true) {
        $headerLine = $reader.ReadLine()
        if ($null -eq $headerLine -or $headerLine -eq "") {
          break
        }
        if ($headerLine -match "^Authorization:\s*Basic\s+(.+)$") {
          $authorization = $Matches[1].Trim()
        }
      }

      $parts = $requestLine -split " ", 3
      $status = "200 OK"
      $body = [byte[]]@()
      $contentType = "text/plain; charset=utf-8"
      $extraHeaders = ""

      if ($parts.Length -lt 2 -or ($parts[0] -ne "GET" -and $parts[0] -ne "HEAD")) {
        $status = "405 Method Not Allowed"
        $body = [System.Text.Encoding]::UTF8.GetBytes("Method not allowed")
      } else {
        $requestUri = [System.Uri]::new("http://127.0.0.1" + $parts[1])
        $relativePath = [System.Uri]::UnescapeDataString($requestUri.AbsolutePath.TrimStart("/"))
        if ([string]::IsNullOrWhiteSpace($relativePath)) {
          $relativePath = "index.html"
        }

        $segments = $relativePath -split "[/\\]"
        $safePath = -not ($segments | Where-Object { $_.StartsWith(".") })
        $filePath = [System.IO.Path]::GetFullPath((Join-Path $root ($relativePath -replace "/", [System.IO.Path]::DirectorySeparatorChar)))
        $rootPrefix = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        $insideRoot = $filePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)

        $isAdminPage = $filePath.Equals($adminFile, [System.StringComparison]::OrdinalIgnoreCase)
        $authenticated = $false
        if ($isAdminPage -and $authorization) {
          try {
            $decodedCredentials = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($authorization))
            $separator = $decodedCredentials.IndexOf(":")
            $authenticated = $separator -ge 0 -and
              $decodedCredentials.Substring(0, $separator) -ceq $username -and
              $decodedCredentials.Substring($separator + 1) -ceq $password
          } catch {
            $authenticated = $false
          }
        }

        if ($isAdminPage -and -not $authenticated) {
          $status = "401 Unauthorized"
          $contentType = "text/plain; charset=utf-8"
          $extraHeaders = "WWW-Authenticate: Basic realm=`"TEAM VAR Admin`", charset=`"UTF-8`"`r`n"
          $body = [System.Text.Encoding]::UTF8.GetBytes("Username atau password admin salah.")
        } elseif ($safePath -and $insideRoot -and (Test-Path -LiteralPath $filePath -PathType Leaf)) {
          $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
          $contentTypes = @{
            ".html" = "text/html; charset=utf-8"
            ".css" = "text/css; charset=utf-8"
            ".js" = "text/javascript; charset=utf-8"
            ".json" = "application/json; charset=utf-8"
            ".txt" = "text/plain; charset=utf-8"
            ".png" = "image/png"
            ".jpg" = "image/jpeg"
            ".jpeg" = "image/jpeg"
            ".webp" = "image/webp"
            ".svg" = "image/svg+xml"
            ".mp3" = "audio/mpeg"
          }
          if ($contentTypes.ContainsKey($extension)) {
            $contentType = $contentTypes[$extension]
          } else {
            $contentType = "application/octet-stream"
          }
          $body = [System.IO.File]::ReadAllBytes($filePath)
        } else {
          $status = "404 Not Found"
          $body = [System.Text.Encoding]::UTF8.GetBytes("Not found")
        }
      }

      $headers = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`n$extraHeaders" +
        "Connection: close`r`n`r`n"
      $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headers)
      $stream.Write($headerBytes, 0, $headerBytes.Length)
      if ($parts.Length -ge 2 -and $parts[0] -eq "GET" -and $body.Length -gt 0) {
        $stream.Write($body, 0, $body.Length)
      }
      $stream.Flush()
    } catch {
      Write-Warning "Permintaan gagal diproses: $($_.Exception.Message)"
    } finally {
      $client.Dispose()
    }
  }
} finally {
  $listener.Stop()
}
