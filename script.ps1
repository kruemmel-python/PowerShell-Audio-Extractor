Add-Type -AssemblyName PresentationFramework

# Lade das XAML
[xml]$xaml = Get-Content -Path "Gui.xaml"

# Erstelle das PowerShell-Fenster aus dem XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Finde die UI-Elemente
$inputFileTextBox = $window.FindName("InputFileTextBox")
$browseButton = $window.FindName("BrowseButton")
$extractButton = $window.FindName("ExtractButton")
$statusTextBlock = $window.FindName("StatusTextBlock")

# Funktion zum Auswählen der Videodatei
$browseButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Videodateien (*.mp4;*.mkv;*.avi)|*.mp4;*.mkv;*.avi|Alle Dateien (*.*)|*.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $inputFileTextBox.Text = $OpenFileDialog.FileName
})

# Funktion zum Extrahieren der Audiodatei
$extractButton.Add_Click({
    $inputFilePath = $inputFileTextBox.Text
    if ([string]::IsNullOrEmpty($inputFilePath) -or -not (Test-Path $inputFilePath)) {
        [System.Windows.MessageBox]::Show("Bitte wählen Sie eine gültige Videodatei aus.") | Out-Null
        return
    }

    $outputFilePath = [System.IO.Path]::ChangeExtension($inputFilePath, ".mp3")

    $statusTextBlock.Text = "Extrahieren..."
    Start-Job -ScriptBlock {
        param ($input, $output)
        & ffmpeg -i $input -q:a 0 -map a $output
    } -ArgumentList $inputFilePath, $outputFilePath | Wait-Job | Out-Null

    $statusTextBlock.Text = "Fertig! Audiodatei gespeichert als: $outputFilePath"
})

# Zeige das Fenster
$window.ShowDialog() | Out-Null
