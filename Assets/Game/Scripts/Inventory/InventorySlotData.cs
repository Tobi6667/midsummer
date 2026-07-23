[System.Serializable]
public class InventorySlotData
{
    public SoInventoryItem item;
    public int amount;

    public InventorySlotData(SoInventoryItem item, int amount)
    {
        this.item = item;
        this.amount = amount;
    }
}