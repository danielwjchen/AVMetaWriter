import AVFoundation
import ArgumentParser
import Foundation

enum SignatureError: Error {
  case exportSessionCreationFailed
  case exportFailed(Error?)
}

func ensureSignatureMetadata(
  inputURL: URL,
  outputURL: URL,
  signature: String
) async throws -> URL {

  let asset = AVAsset(url: inputURL)
  let metadata = asset.metadata

  // Check if signature exists
  let signatureExists = metadata.contains { item in
    guard let value = item.value as? String else { return false }
    return value.contains(signature)
  }

  if signatureExists {
    return inputURL
  }

  guard
    let exportSession = AVAssetExportSession(
      asset: asset,
      presetName: AVAssetExportPresetPassthrough
    )
  else {
    throw SignatureError.exportSessionCreationFailed
  }

  exportSession.outputURL = outputURL

  // Detect file type
  let fileExtension = inputURL.pathExtension.lowercased()

  let metadataItem = AVMutableMetadataItem()
  metadataItem.keySpace = .common
  metadataItem.value = signature as NSString
  metadataItem.extendedLanguageTag = "und"
  metadataItem.key = AVMetadataKey.commonKeyDescription as NSString

  if fileExtension == "mp4" {
    exportSession.outputFileType = .mp4
  } else {
    exportSession.outputFileType = .mov
  }

  var newMetadata = metadata
  newMetadata.append(metadataItem)
  exportSession.metadata = newMetadata

  await exportSession.export()

  return outputURL
}

@main
struct AVMetaWriter: AsyncParsableCommand {
  @Option(help: "The path to the input AV file.")
  var input: String

  @Option(help: "The path to save the signed AV file.")
  var output: String

  func run() async throws {
    let inputURL = URL(fileURLWithPath: input)
    let outputURL = URL(fileURLWithPath: output)

    let _ = try await ensureSignatureMetadata(
      inputURL: inputURL, outputURL: outputURL, signature: "My Signature"
    )
    print("Metadata written successfully to \(output)")
  }
}
