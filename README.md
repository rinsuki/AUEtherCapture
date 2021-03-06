# AUEtherCapture

Work In Progress...

Among Us のパケットをキャプチャし、
- [aureplayer](https://github.com/rinsuki/aureplayer) で再生できるリプレイデータを出力
- [auethermuteproxy](https://github.com/rinsuki/auethermuteproxy) と組み合わせて AutoMuteUs のキャプチャーソフトとして動作

します。

## Requirements

- macOS: only tested on macOS Big Sur but might works in macOS Catalina (10.15) and older
- Linux: libpcap
- Windows: Windows 10 (required by Swift) and [Npcap](https://nmap.org/npcap/#download)
  - ⚠️ Windows 7/8/8.1 doesn't supported (because Swift requires Windows 10), and might not work in old Windows 10 version (like 1909). only tested on 20H2

## Download

GitHub Actions でコミット毎に自動ビルドを回しています。ビルド成果は各コミットのArtifactsからダウンロードできます (GitHub にログインしていないと表示されません)。

## Tasks (1/4)

- [x] Linked with AutoMuteUs https://automute.us/ (requires [auethermuteproxy](https://github.com/rinsuki/auethermuteproxy) for interact with AutoMuteUs server)
- [ ] GUI: Create GUI Front-end for macOS
- [ ] GUI: Create GUI Front-end for Windows
- [ ] GUI: Create GUI Front-end for Linux (GTK?)
