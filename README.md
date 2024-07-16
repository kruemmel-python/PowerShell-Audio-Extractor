
# PowerShell Audio Extractor

Ein PowerShell-Skript zur Extraktion von Audiodateien aus Videodateien mit einer grafischen Benutzeroberfläche (GUI).

## Voraussetzungen

- **FFmpeg**: Ein leistungsstarkes Tool zur Audio- und Videobearbeitung. Es muss installiert und in den Systempfad aufgenommen werden.
  - [FFmpeg Download](https://ffmpeg.org/download.html)
  
- **PowerShell**: Die Skripte sind für PowerShell konzipiert, welches standardmäßig in Windows enthalten ist.

## Installation von FFmpeg

1. Besuche die [FFmpeg Downloadseite](https://ffmpeg.org/download.html) und lade die passende Version für dein Betriebssystem herunter.
2. Entpacke die heruntergeladene Datei.
3. Füge den Pfad zu den `ffmpeg`-Binaries (z.B. `C:\ffmpeg\bin`) zum Systempfad hinzu:
   - Öffne die Systemeigenschaften (Win + Pause).
   - Gehe zu "Erweiterte Systemeinstellungen".
   - Klicke auf "Umgebungsvariablen".
   - Füge den Pfad zu `ffmpeg\bin` zur Variable `Path` hinzu.

## Projektstruktur

Dieses Projekt besteht aus zwei Hauptdateien:
- **Gui.xaml**: Die XAML-Datei, die die grafische Benutzeroberfläche definiert.
- **script.ps1**: Das PowerShell-Skript, das die GUI lädt und die Audioextraktion durchführt.

## Dateien

### Gui.xaml

Diese Datei definiert die grafische Benutzeroberfläche (GUI) für das Skript. Sie enthält ein Textfeld zur Auswahl der Videodatei, einen Button zum Durchsuchen und einen Button zum Starten des Extraktionsprozesses.

```xml
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Audio Extrahierer" Height="200" Width="400">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <TextBox Name="InputFileTextBox" Grid.Row="0" Grid.Column="0" Margin="10" Width="300" Height="25" VerticalAlignment="Center"/>
        <Button Name="BrowseButton" Grid.Row="0" Grid.Column="1" Margin="10" Width="50" Height="25" VerticalAlignment="Center">...</Button>
        <Button Name="ExtractButton" Grid.Row="1" Grid.ColumnSpan="2" Margin="10" Width="100" Height="25" VerticalAlignment="Center" HorizontalAlignment="Center">Extrahieren</Button>
        <TextBlock Name="StatusTextBlock" Grid.Row="2" Grid.ColumnSpan="2" Margin="10" VerticalAlignment="Center" HorizontalAlignment="Center" TextAlignment="Center"/>
    </Grid>
</Window>
```

### script.ps1

Dieses PowerShell-Skript lädt die GUI aus der `Gui.xaml`-Datei, ermöglicht die Auswahl einer Videodatei und extrahiert die Audiodatei mithilfe von `ffmpeg`.

```powershell
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
```

### Erklärung des Skripts

- **Zeile 1**: `Add-Type -AssemblyName PresentationFramework` lädt die PresentationFramework-Assembly, die für die WPF-Integration benötigt wird.
- **Zeile 4-6**: Lädt die GUI-Definition aus der `Gui.xaml`-Datei.
- **Zeile 9-13**: Findet die definierten UI-Elemente (TextBox, Buttons, TextBlock) in der geladenen GUI.
- **Zeile 16-23**: Definiert die Aktion für den "Durchsuchen"-Button, um eine Videodatei auszuwählen.
- **Zeile 26-41**: Definiert die Aktion für den "Extrahieren"-Button, um die Audiodatei aus der ausgewählten Videodatei zu extrahieren. Dabei wird `ffmpeg` in einem Hintergrundjob verwendet, um die Audioextraktion durchzuführen.
- **Zeile 44**: Zeigt das Fenster an und wartet, bis es geschlossen wird.

## Verwendung

1. **Clone das Repository**:
   ```sh
   git clone https://github.com/dein-benutzername/PowerShell-Audio-Extractor.git
   cd PowerShell-Audio-Extractor
   ```

2. **Stelle sicher, dass die `Gui.xaml` und `script.ps1` Dateien im gleichen Verzeichnis liegen**.

3. **Öffne PowerShell und führe das Skript aus**:
   ```sh
   .\script.ps1
   ```

4. **Verwende die GUI, um eine Videodatei auszuwählen und die Audiodatei zu extrahieren**:
   - Klicke auf den "..."-Button, um eine Videodatei auszuwählen.
   - Klicke auf den "Extrahieren"-Button, um die Audiodatei in höchster Qualität zu extrahieren.

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
