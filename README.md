# RecorodToText
このアプリは、オーディオインタフェースから入力された音声を録音し、一定期間毎に自動で文字起こしとサマリーを作成します。  
文字起こしの間隔は設定画面でカスタマイズできます。  

このアプリは`macOS`に対応していますが、使用しているライブラリはモバイルデバイスやWindowsでもサポートしているため適切な環境を用意すればこれらのプラットフォームでもアプリを利用できると思います。ただし録音処理の動作確認やUIの改善が必要だと思います。

# 制限事項
何時間もの長時間録音には対応していません。理由は以下の通りです。  

音声ファイルはCacheディレクトリに残りますが文字起こししたデータやサマリー文字列はメモリ上に保持しているだけで永続領域に書き込んでるわけではないのでアプリを閉じると無くなります。そのため途中でエラーになったりフリーズした場合はデータは全部消えます。  

また、サマリーを作成する際、Context長を考慮した作りにしていません。理由は色々ありましたが、まず個人的に利用する目的で30分程度のMTGで使う想定でした。  
人間が1分間に話せる文字数から逆算して検討した結果、分割してサマリーを作るより全てつなげてサマリーを作った方がブレが少ないという結論になり、今の作りにしています。  

従って上記が考慮できれば長時間配信も行けると思います。

# 設計
本当は`Python`を使えばもっと柔軟に音声データの録音や処理ができたのですが、`Flutter`で実装したかったのでこうなりました。

## 録音機能
システムのオーディオ入力をキャプチャして録音します。連続性を確保するため録音は一時停止せずに連続して行い、バックグラウンドで定期的に音声データのセグメントを保存し、それらを非同期に処理するアプローチを検討します。

## テキスト変換機能
`Whisper API`を使用して文字起こしします。  
文字起こしした内容は`gpt-3.5-turbo`モデルを使用してフィラーを除去しようと考えていましたが、`Whisper API`がデフォルトでフィラーをある程度削除してくれるようなので一旦不要としました。  
使ってみて気になるようなら検討します。

## サマリー生成
各音声データの文字列を順番に結合し`gpt-4-turbo`モデルを使用してサマリーします。  
最初は指定したContext長になるまで順番につなげてサマリーを段階的に作成しようと考えましたが、今のContext長は以前に比べて格段に長くなったことと、分割してサマリーを作るより全てつなげてサマリーを作った方がブレが少ないという結論になり、まとめて作成することにしました。  

# TODO
- サマリー生成機能: エラー時に再作成できるようにする
- 共通: 録音のリセット機能実装
