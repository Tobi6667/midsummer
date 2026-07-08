using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Equipment : Item
{
    public int Intellect { get; set; }
    public int Agility { get; set; }
    public int Stamina { get; set; }
    public int Strength { get; set; }
    public int Constitution { get; set; }
    public Equipment()
    {

    }
    public Equipment(string itemName, string description, ItemType itemType,
    Quality quality, string spriteNeutral,
    string spriteHighlighted, int maxSize,int intellect,int agility, int stamina,int strength, int constitution) :base(itemName, description, itemType, quality, spriteNeutral, spriteHighlighted, maxSize)
    {
        Agility = agility;
        Intellect = intellect;
        Stamina = stamina;
        Strength = strength;
        Constitution = constitution;
    }
    public override void Use(Slot slot, ItemScript item)
    {

        CharacterPanel.Instance.EquipItem(slot, item);
    }
    public override string GetToolTip()
    {
        string stats = string.Empty;
        if (Strength > 0)
        {
            stats += "\n+" + Strength.ToString() + " Strength";

        }
        if (Intellect > 0)
        {
            stats += "\n+" + Intellect.ToString() + " Intellect";

        }
        if (Agility > 0)
        {
            stats += "\n+" + Agility.ToString() + " Agility";

        }
        if (Stamina > 0)
        {
            stats += "\n+" + Stamina.ToString() + " Stamina";

        }
        if (Constitution > 0)
        {
            stats += "\n+" + Constitution.ToString() + " Constitution";

        }

        string itemTip = base.GetToolTip();
        return string.Format("{0}" +"<size=14>{1}</size>", itemTip, stats);

    }
}
