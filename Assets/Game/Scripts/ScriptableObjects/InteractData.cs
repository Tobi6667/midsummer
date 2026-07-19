using System.Collections.Generic;

[System.Serializable]
public class InteractData
{
    public EInteractionType interactionType;

    public string dialogText;

    public List<SoInteractionAction> actions;


    // what happens after completion
    public EStoryEvent completedEvent;
}