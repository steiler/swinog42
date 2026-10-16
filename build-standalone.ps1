# Builds sdc-section-standalone.html: sdc-section.html with reveal.js CSS/JS inlined (no external requests).
# Usage: powershell -ExecutionPolicy Bypass -File build-standalone.ps1
$ErrorActionPreference = 'Stop'
$dir  = $PSScriptRoot
$html = [IO.File]::ReadAllText("$dir\sdc-section.html")

function Read-Asset($rel) {
  $t = [IO.File]::ReadAllText("$dir\$rel")
  $t = $t -replace '@import url\([^)]*\);', ''      # theme font import would be an external request
  $t = $t -replace '//# sourceMappingURL=.*', ''
  return $t.Replace('</script>', '<\/script>')
}

function Replace-Tag($html, $tag, $replacement) {
  if (-not $html.Contains($tag)) { throw "Tag not found: $tag" }
  return $html.Replace($tag, $replacement)
}

foreach ($css in 'reset.css','reveal.css','theme/white.css') {
  $tag = "<link rel=`"stylesheet`" href=`"reveal/$css`">"
  $html = Replace-Tag $html $tag ("<style>`n" + (Read-Asset "reveal\$css") + "`n</style>")
}
foreach ($js in 'reveal.js','plugin/notes/notes.js') {
  $tag = "<script src=`"reveal/$js`"></script>"
  $html = Replace-Tag $html $tag ("<script>`n" + (Read-Asset "reveal\$js") + "`n</script>")
}

[IO.File]::WriteAllText("$dir\sdc-section-standalone.html", $html, (New-Object Text.UTF8Encoding($false)))
"Wrote sdc-section-standalone.html ($([math]::Round((Get-Item "$dir\sdc-section-standalone.html").Length/1KB)) KB)"
