
if which swiftlint >/dev/null; then
    cd "${SRCROOT}/${TARGET_NAME}"
    swiftlint autocorrect
    swiftlint

else
    echo "warning: SwiftLint not installed, you can install it from  https://github.com/realm/SwiftLint"
fi
