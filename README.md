# Rec Room Reborn iOS

An unofficial SwiftUI companion app for the RecFlare project.

## What it does
- Shows a simple Rec Room Reborn-themed home screen.
- Checks whether `https://ns.recflare.net` responds.
- Provides links to RecFlare project resources.

## What it does not do
This is a companion app, not the Rec Room game client. It does not run the Windows client or provide game sessions. It is not affiliated with Rec Room Inc.

## Build
The GitHub Actions workflow builds an **unsigned** iOS IPA on a macOS runner. An unsigned IPA must be signed with an Apple development/distribution certificate and provisioning profile before it can be installed on a normal iPhone.

To start a build, open **Actions → Build Rec Room Reborn iOS IPA → Run workflow**.
