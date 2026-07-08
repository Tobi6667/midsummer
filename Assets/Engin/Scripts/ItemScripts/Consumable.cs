using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Consumable : Item
{
    public int Health { get; set; }
    public int Mana { get; set; }
    public Consumable()
    {

    }
    public Consumable(string itemName, string description, ItemType itemType,
    Quality quality, string spriteNeutral, 
    string spriteHighlighted, int maxSize, int health, int mana)
        :base(itemName,description,itemType,quality,spriteNeutral, spriteHighlighted, maxSize)
    {
       
        Health = health;
        Mana = mana;
    }
   
    public override string GetToolTip()
    {
        string stats = string.Empty;
        if (Mana > 0)
        {
            stats += "\n Restores " + Mana.ToString() + " Mana";

        }
        if (Health > 0)
        {
            stats += "\n Restores" + Health.ToString() + " Health";

        }

        string itemTip = base.GetToolTip();

        return string.Format("{0}" + "<size=14> {1}</size>", itemTip, stats);

    }

    public override void Use(Slot slot, ItemScript item)
    {
        Debug.Log("gGG");
    }
}
