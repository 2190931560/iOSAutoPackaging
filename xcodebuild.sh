#注意：脚本目录和WorkSpace目录在同一个目录
#工程名字(Target名字)
APP_NAME="xxx"

#build direct
BUILD_DIR=./build

#导出plist
Export_appstore=./ExportOptions-appstore.plist
Export_adhot=./ExportOptions-adhot.plist

echo "~~~~~~~~~~~~选择打包方式(输入序号)~~~~~~~~~~~~~~~"
echo "        1 adHoc"
echo "        2 AppStore"

# 读取用户输入并存到变量里
read method

if [ "$method" = "1" ];then
    echo "开始打包上传到 fir.im"
    #清理build目录
    rm -fr ${BUILD_DIR}/adhoc
    #clean工程
    xcodebuild -workspace  ${APP_NAME}.xcworkspace  -scheme ${APP_NAME}  -configuration InHouse clean | xcpretty
    #生成archive
    xcodebuild -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME}  -configuration InHouse -archivePath ${BUILD_DIR}/adhoc/${APP_NAME}.xcarchive -derivedDataPath ${BUILD_DIR}/adhoc archive | xcpretty
    #生成ipa
    xcodebuild -exportArchive -archivePath ${BUILD_DIR}/adhoc/${APP_NAME}.xcarchive -exportPath ${BUILD_DIR}/adhoc -exportOptionsPlist ${Export_adhot} | xcpretty
    #拷贝dsym文件
    cp -r ${BUILD_DIR}/adhoc/Build/Intermediates.noindex/ArchiveIntermediates/RoWrite/BuildProductsPath/InHouse-iphoneos/${APP_NAME}.app.dSYM ${BUILD_DIR}/adhoc/${APP_NAME}.app.dSYM
    #登录fir.im
    fir login -T xxxxxxxxxxxxxxxxx
    #上传fir.im
    fir publish ${BUILD_DIR}/adhoc/${APP_NAME}.ipa
elif [ "$method" = "2" ];then
    echo "开始打包appstore版本"
    #清理build目录
    rm -fr ${BUILD_DIR}/appstore
    #clean工程
    xcodebuild -workspace  ${APP_NAME}.xcworkspace  -scheme ${APP_NAME}  -configuration Release clean | xcpretty
    #生成archive
    xcodebuild -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME}  -configuration Release -archivePath ${BUILD_DIR}/appstore/${APP_NAME}.xcarchive -derivedDataPath ${BUILD_DIR}/appstore archive | xcpretty
    #生成ipa
    xcodebuild -exportArchive -archivePath ${BUILD_DIR}/appstore/${APP_NAME}.xcarchive -exportPath ${BUILD_DIR}/appstore -exportOptionsPlist ${Export_appstore} | xcpretty
    cp -r ${BUILD_DIR}/appstore/Build/Intermediates.noindex/ArchiveIntermediates/RoWrite/BuildProductsPath/Release-iphoneos/${APP_NAME}.app.dSYM ${BUILD_DIR}/appstore/${APP_NAME}.app.dSYM
else
    echo "无效输入"
    exit 1
fi
