totalStart=`date +%s`

fileNameWithExtension="${0##*/}" # 含副檔名
fileName="${fileNameWithExtension%.*}" # 不含副檔名

# 上傳IPA 需修改的參數
appleID="bobsonliu@innov.tvbs.com.tw"
keychainName="testflight"
teamID="SANBC4ZN9M"
appleIDPassword=$(security find-generic-password -w -s "${keychainName}" -a "${appleID}")

# 打包 IPA 需修改的參數
dir="${0%/*}/../"
projectPath="$(builtin cd "$dir"; pwd)" # 取得點雨下路徑打包IPA的上一層 path
exportFolder="打包IPA"
projectName='healthmvp'
scheme='healthmvp'
infoPlist="Info.plist"

CFBundleName=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "${projectPath}/${projectName}/${infoPlist}")
version=$( cat "${projectPath}/${projectName}.xcodeproj/project.pbxproj" | grep -m1 'MARKETING_VERSION' | cut -d'=' -f2 | tr -d ';' | tr -d ' ' )
defaultIPAName="${CFBundleName}.ipa"
newADIPAName="${CFBundleName} ad_hoc ${version}.ipa"
newAppStoreIPAName="${CFBundleName} appstore ${version}.ipa"

workspace="${projectName}.xcworkspace"

currentDate="$(date +'%y%m%d_%H%M%S')"
folderName="${projectName}_${currentDate}"
archivePath="${HOME}/Desktop/${folderName}/${fileName}.xcarchive"

# AppStore ExportOptionsPlist
appStoreExportOptionsPlist="${projectPath}/${exportFolder}/AppStoreExportOptions.plist"
appStoreExportPath="${HOME}/Desktop/${folderName}/${fileName}_appstore"

# Ad-hoc ExportOptionsPlist
adHocExportOptionsPlist="${projectPath}/${exportFolder}/AdHocExportOptions.plist"
adHocExportPath="${HOME}/Desktop/${folderName}/${fileName}_adhoc"

# echo

echo "\r\necho variables..."

echo "fileNameWithExtension = ${fileNameWithExtension}"
echo "fileName = ${fileName}"

echo "projectPath = ${projectPath}"
echo "projectName = ${projectName}"
echo "scheme = ${scheme}"
echo "${CFBundleName}"
echo "adIPAName = ${adIPAName}"

echo "version = ${version}"

echo "defaultIPAName = ${defaultIPAName}"
echo "newADIPAName = ${newADIPAName}"
echo "newAppStoreIPAName = ${newAppStoreIPAName}"

echo "workspace = ${workspace}"

echo "currentDate = ${currentDate}"
echo "folderName = ${folderName}"
echo "archivePath = ${archivePath}"

echo "appStoreExportOptionsPlist = ${appStoreExportOptionsPlist}"
echo "appStoreExportPath = ${appStoreExportPath}"

echo "adHocExportOptionsPlist = ${adHocExportOptionsPlist}"
echo "adHocExportPath = ${adHocExportPath}"

echo "\r\n1.切換目錄"
cd "${projectPath}"

echo "\r\n2.archive"
start=`date +%s`
xcodebuild archive -workspace "${workspace}" -scheme "${scheme}" -sdk iphoneos -archivePath "${archivePath}"
end=`date +%s`
archiveDuration=$((end-start))

echo "\r\n3.1 匯出 AppStore ipa"
start=`date +%s`
xcodebuild -exportArchive -archivePath "${archivePath}" -exportOptionsPlist "${appStoreExportOptionsPlist}" -exportPath ${appStoreExportPath} -allowProvisioningUpdates
end=`date +%s`
exportAppStoreIPADuration=$((end-start))

echo "\r\n3.2.匯出 Ad-hoc ipa"
start=`date +%s`
xcodebuild -exportArchive -archivePath "${archivePath}" -exportOptionsPlist "${adHocExportOptionsPlist}" -exportPath ${adHocExportPath} -allowProvisioningUpdates
end=`date +%s`
exportAdHocIPADuration=$((end-start))

echo "\r\n4.重新命名 ipa"
mv "${adHocExportPath}/${defaultIPAName}" "${adHocExportPath}/${newADIPAName}"
mv "${appStoreExportPath}/${defaultIPAName}" "${appStoreExportPath}/${newAppStoreIPAName}"

echo "\r\n5.打開ipa目錄"
open "${adHocExportPath}"

# 打開Google Drive
open "https://drive.google.com/drive/folders/1ga7HyH58nw2uE54mXRLGYE1O7jm0LktP"

echo "\r\n輸出時間"

totalEnd=`date +%s`
totalDuration=$((totalEnd-totalStart))

echo "archiveDuration = ${archiveDuration} 秒"
echo "exportAppStoreIPADuration = ${exportAppStoreIPADuration} 秒"
echo "exportAdHocIPADuration = ${exportAdHocIPADuration} 秒"
echo "totalDuration = ${totalDuration} 秒"

echo "\r\n打包IPA完成"

#################### 準備上傳到TestFlight ####################

echo "\r\n6.準備上傳到TestFlight"

xcrun altool --upload-app -f "${appStoreExportPath}/${newAppStoreIPAName}" -t ios -u "${appleID}" -p "${appleIDPassword}" --asc-provider "${teamID}"

echo "\r\n總時間(含上傳)"
totalEnd=`date +%s`
totalDuration=$((totalEnd-totalStart))

echo "totalDuration = ${totalDuration} 秒"

echo "\r\nIPA 上傳到 Testflight 完成"

open "https://appstoreconnect.apple.com/apps/1555214796/testflight/ios" # 開啟 dev testflight

############################################################
