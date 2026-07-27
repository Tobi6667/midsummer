using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    CharacterController cc;
    Animator anim;
    bool isSpringting;
    [System.Serializable]
    public class AnimationStrings
    {
        public string forward = "forward";
        public string strafe = "strafe";
        public string sprint = "sprint";
        public string aim = "aim";
        public string pull = "pullString";
        public string fire = "fire";
    }
    [SerializeField]
    public AnimationStrings animStrings;
    public void CharacterAim(bool aiming)
    {
        anim.SetBool(animStrings.aim, aiming);
    }
    public void CharacterPullString(bool pull)

    {
        anim.SetBool(animStrings.pull, pull);
    }
    public void CharacterFireArrow()
    {
        anim.SetTrigger(animStrings.fire);
    }

    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
        anim = GetComponent<Animator>();
    }
    public void AnimateCharacter(float forward, float strafe)
    {
        anim.SetFloat(animStrings.forward, forward);
        anim.SetFloat(animStrings.strafe, strafe);

    }
    public void SprintCharacter(bool isSprinting)
    {
        anim.SetBool(animStrings.sprint, isSprinting);
    }
    // Update is called once per frame
    void Update()
    {


    }

}


