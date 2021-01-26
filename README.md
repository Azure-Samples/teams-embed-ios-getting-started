# Quickstart: Add Meeting Composite to your iOS app

For full instructions on how to build this code sample from scratch, look at [Quickstart: Add meeting composite to your iOS app](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/meeting/getting-started-with-meeting-composite?pivots=platform-iOS)

## Prerequisites

To complete this tutorial, you’ll need the following prerequisites:

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F). 
- A Mac running [Xcode](https://go.microsoft.com/fwLink/p/?LinkID=266532), along with a valid developer certificate installed into your Keychain.
- A deployed Communication Services resource. [Create a Communication Services resource](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/create-communication-resource).
- A [User Access Token](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/access-tokens?pivots=programming-language-csharp) for your Azure Communication Service.
- Create a `Podfile` for your application to fetch `AzureCore.framework` and `AzureCommunication.framework` using CocoaPods.

## Code Structure

- **./MeetingSDKGettingStarted/ViewController.swift:** Contains core UI and logic for calling SDK integration.
- **./MeetingSDKGettingStarted.xcodeproj:** Xcode project for the sample.

## Object model

The following classes and interfaces used in the quickstart handle some of the major features of the Azure Communication Services Meeting Composite library:

| Name                                  | Description                                                  |
| ------------------------------------- | ------------------------------------------------------------ |
| MeetingClient | The MeetingClient is the main entry point to the Meeting library.|
| MeetingClientDelegate | The CallAgent is used to start and manage calls. |
| JoinOptions | JoinOptions are used for configurable options such as display name, and is the microphone muted, etc. | 
| CallState | The CallState is used to for reporting call state changes. The options are as follows: connecting, waitingInLobby, connected, and ended. |

## Before running sample code

1. Open an instance of PowerShell, Windows Terminal, Command Prompt or equivalent and navigate to the directory that you'd like to clone the sample to.
2. `git clone https://github.com/Azure-Samples/meeting-sdk-ios-getting-started`
3. With the `Access Token` procured in pre-requisites, add it to the **MeetingSDKGettingStarted/ViewController.swift** file. Assign your access token in line 35:
   ```userCredential = try CommunicationUserCredential(token: "<USER_TOKEN_HERE>")```

## Run the sample

You can build an run your app on iOS simulator by selecting **Product** > **Run** or by using the (&#8984;-R) keyboard shortcut.

![Final look and feel of the quick start app](../Media/quickstart-android-call-echobot.png)