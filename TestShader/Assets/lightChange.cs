using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class lightChange : MonoBehaviour {
    // Use this for initialization
    public float start;
    void Start () {
        start = Time.realtimeSinceStartup;
    }

    // Update is called once per frame
    void Update() {
        transform.rotation = Quaternion.Euler(transform.rotation.x + Time.realtimeSinceStartup * 30 - start, transform.rotation.y + Time.realtimeSinceStartup * 30 - start, transform.rotation.z);
    }
}
