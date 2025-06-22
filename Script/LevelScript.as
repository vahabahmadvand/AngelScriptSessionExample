class ALevelScript : ALevelScriptActor
{
	UPROPERTY()
	TSubclassOf<UMenuWidget> WidgetClass;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		auto PlayerController = Gameplay::GetPlayerController(0);
		if (PlayerController != nullptr)
		{
			auto Menu = WidgetBlueprint::CreateWidget(WidgetClass, PlayerController);
			if (Menu != nullptr)
			{
				Menu.AddToViewport();
			}
		}
	}
};