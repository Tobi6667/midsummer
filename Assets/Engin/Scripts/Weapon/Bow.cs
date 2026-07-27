using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bow : MonoBehaviour
{
    [System.Serializable]
    public class BowSettings
    {
        [Header("Arrow Settings")]
        public float arrowCount;
        public Rigidbody arrowPrefab;
        public Transform arrowPos;
        public Transform arrowEquipParent;
        public float arrowForce = 3;

        [Header("Bow Equip & UnEquip Settings")]
        public Transform equipPos;
        public Transform unequipPos;
        public Transform unequipParent;
        public Transform equipParent;
        [Header("Bow String Settings")]
        public Transform bowString;
        public Transform stringInitialPos;
        public Transform stringHandPullPos;
        public Transform stringInitialParent;



    }
    [SerializeField]
    BowSettings bowSettings;
    [Header("CrossHair Settings")]
    public GameObject crossHairPrefab;
    public GameObject currentCrossHair;
    public Rigidbody currentArrow;

    bool canPullString;
    bool canFireArrow;
    void Start()
    {
        
      
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void PickArrow()
    {
        bowSettings.arrowPos.gameObject.SetActive(true);
      // currentArrow= Instantiate(bowSettings.arrowPrefab, bowSettings.arrowPos.position, bowSettings.arrowPos.rotation);
    }
    public void DisableArrow()
    {
        bowSettings.arrowPos.gameObject.SetActive(false);
        // currentArrow= Instantiate(bowSettings.arrowPrefab, bowSettings.arrowPos.position, bowSettings.arrowPos.rotation);
    }
    public void PullString()
        
    {
        bowSettings.bowString.transform.position = bowSettings.stringHandPullPos.position;
        bowSettings.bowString.transform.parent = bowSettings.stringHandPullPos;
    }
    public void ReleaseString()
    {
        bowSettings.bowString.transform.position = bowSettings.stringInitialPos.position;
        bowSettings.bowString.transform.parent = bowSettings.stringInitialParent;
    }
    void EquipBow()
    {
        transform.position = bowSettings.equipPos.position;
        transform.rotation = bowSettings.equipPos.rotation;
        transform.parent = bowSettings.equipParent;
    }
    void UnEquipBow()
    {
        transform.position = bowSettings.unequipPos.position;
        transform.rotation = bowSettings.unequipPos.rotation;
        transform.parent = bowSettings.unequipParent;
    }
    public void ShowCrossHair(Vector3 crossHairPos)
    {
        if (!currentCrossHair)
            currentCrossHair = Instantiate(crossHairPrefab) as GameObject;
        currentCrossHair.transform.position = crossHairPos;
        currentCrossHair.transform.LookAt(Camera.main.transform);
    }
    public void RemoveCrossHair()
    {
        if (currentCrossHair)
            Destroy(currentCrossHair);
    }
    public void Fire(Vector3 hitPoint )
    {
        Vector3 dir = hitPoint - bowSettings.arrowPos.position;
        currentArrow = Instantiate(bowSettings.arrowPrefab, bowSettings.arrowPos.position, bowSettings.arrowPos.rotation);
        currentArrow.AddForce(dir * bowSettings.arrowForce, ForceMode.VelocityChange);
        
    }
}
