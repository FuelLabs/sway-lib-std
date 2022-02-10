#[tokio::test]
async fn bar() {
    assert_eq!(false, false);
}

#[tokio::test]
async fn blar() {
    assert_eq!(false, true);
}