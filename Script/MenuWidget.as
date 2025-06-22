class UMenuWidget : UUserWidget
{
	UPROPERTY(BindWidget)
	UButton HostButton;

	UPROPERTY(BindWidget)
	UButton JoinButton;

	UPROPERTY()
	FString MapName = "ThirdPersonMap";

	private UScriptSessionSubsystem SessionSubsystem;
	int NumPublicConnections = 5;

	UFUNCTION(BlueprintOverride)
	void PreConstruct(bool bIsDesignTime)
	{
		HostButton.OnClicked.AddUFunction(this, n"HostButtonClicked");
		JoinButton.OnClicked.AddUFunction(this, n"JoinButtonClicked");
	}

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		SessionSubsystem = Cast<UScriptSessionSubsystem>(Subsystem::GetGameInstanceSubsystem(UScriptSessionSubsystem::StaticClass()));

		if (SessionSubsystem != nullptr)
		{
			SessionSubsystem.OnCreateSessionCompleteEvent.AddUFunction(this, n"OnCreateSession");
			SessionSubsystem.OnFindSessionsCompleteEvent.AddUFunction(this, n"OnFindSession");
		}
	}

	UFUNCTION()
	private void HostButtonClicked()
	{
		HostButton.SetIsEnabled(false);
		if (System::IsValid(SessionSubsystem))
		{
			SessionSubsystem.CreateSession(NumPublicConnections, false);
		}
	}

	UFUNCTION()
	private void JoinButtonClicked()
	{
		JoinButton.SetIsEnabled(false);
		if (System::IsValid(SessionSubsystem))
		{
			SessionSubsystem.FindSessions(100, false);
		}
	}

	UFUNCTION()
	private void OnCreateSession(bool bSuccessful)
	{
		FString PathToLobby = f"{MapName}?listen";

		if (bSuccessful)
		{
			GetWorld().ServerTravel(PathToLobby, true, false);
		}
		else
		{
			Log("Failed to create session!");
			HostButton.SetIsEnabled(true);
		}
	}

	UFUNCTION()
	private void OnFindSession(const TArray<FScriptSessionResult>&in SessionResults, bool bWasSuccessful)
	{
		if (System::IsValid(SessionSubsystem))
		{
			for (auto Result : SessionResults)
			{
				SessionSubsystem.JoinGameSession(Result);
				return;
			}
		}

		if (!bWasSuccessful || SessionResults.Num() == 0)
		{
			JoinButton.SetIsEnabled(true);
			Log("Failed to find session!");
		}
	}

	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		RemoveFromParent();
	}
};