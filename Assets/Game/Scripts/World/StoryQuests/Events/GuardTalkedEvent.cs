using UnityEngine;

public struct GuardTalkedEvent : IGameEvent
{
    public NPCInteractionComponent npc;
    public EnemyBase spawnCharacter;
    public Vector3 spawnPos;

    public GuardTalkedEvent(
        NPCInteractionComponent npc,
        EnemyBase character,
        Vector3 spawnPos)
    {
        this.npc = npc;
        this.spawnCharacter = character;
        this.spawnPos = spawnPos;
    }
}