using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Xml.Serialization;
using System.IO;

public enum Category { Equipment, Weapon, Consumable}
public class ItemManager : MonoBehaviour {

    public ItemType itemType;
    public Quality quality;
    public Category category;
    public string spriteNeutral;
    public string spriteHighlighted;
    
    public string itemName;
    public string description;
    public int maxSize;
    public int intellect;
    public int agility;
    public int stamina;
    public int strength;
    public int constitution;
    public int attackSpeed;
    public int health;
    public int mana;
    public void CreateItem()
    {
        ItemContainer itemContainer = new ItemContainer();
        Type[] itemTypes = { typeof( Equipment ), typeof( Weapon), typeof( Consumable )};
        FileStream fs = new FileStream(Path.Combine(Application.streamingAssetsPath,"items.xml")
            , FileMode.Open);

        XmlSerializer serializer = new XmlSerializer(typeof(ItemContainer),itemTypes);
        itemContainer = (ItemContainer)serializer.Deserialize(fs);
        serializer.Serialize(fs, itemContainer);
        fs.Close();
        switch (category)
        {
            case Category.Equipment:
                itemContainer.Equipment.Add(new Equipment(itemName, description, itemType, quality,
                    spriteNeutral, spriteHighlighted, maxSize, intellect, agility, stamina, strength,constitution));
                break;
            case Category.Weapon:
                itemContainer.Weapons.Add(new Weapon(itemName, description, itemType, quality,
                    spriteNeutral, spriteHighlighted, maxSize, intellect, 
                    agility, stamina, strength,constitution,attackSpeed));
                break;
            case Category.Consumable:
                itemContainer.Consumables.Add(new Consumable(itemName, description, itemType, quality,
                    spriteNeutral, spriteHighlighted, maxSize, health, mana));
                break;
            default:
                break;
        }
        fs=new FileStream(Path.Combine(Application.streamingAssetsPath, "items.xml")
            , FileMode.Create);
        serializer.Serialize(fs, itemContainer);
        fs.Close();
    }



}
