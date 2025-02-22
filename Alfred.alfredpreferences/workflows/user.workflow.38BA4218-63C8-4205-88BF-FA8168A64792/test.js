/**
 * 验证码短信模版
 */
const {readCaptchaFromMessage, readSubjectFromMessage, preProcessMessage} = require("./index");
const code1 = readCaptchaFromMessage('您的验证码是：2498，有效期为10分钟，请尽快验证！The verification code is 2498. It is valid for 10 minutes.');
console.log(code1, code1 === '2498');

const code2 = readCaptchaFromMessage('【Google】G-495968 是您的 Google 驗證碼。');
console.log(code2, code2 === '495968');

const code3 = readCaptchaFromMessage('尊敬的客户，验证码：133706，您正在进行登录账户，有效期2分钟。买健康险，就上平安健康APP！【平安健康险】');
console.log(code3,code3 === '133706');

const code4 = readCaptchaFromMessage(preProcessMessage('尊敬的用户，您可以直接回复指令进行业务查询或办理：\n' +
  ' 00：手机上网流量查询\n' +
  ' 01：账户余额\n' +
  ' 02：实时话费\n' +
  ' 03：常用办理业务\n' +
  ' 04：常用查询业务\n' +
  ' 05：充值卡充值\n' +
  ' 【抗击疫情，服务不停！使用中国联通APP，足不出户交话费、查余额、办业务，免流量看电影、玩游戏，点击 http://u.10010.cn/khddx ，马上拥有】'));

console.log(code4, code4 === null);

const code5 = readCaptchaFromMessage('【BOSS直聘】登录验证码：780929，30分钟内有效。工作人员不会向您索要验证码，切勿将验证码提供给他人，谨防被骗。');
console.log(code5, code5 === '780929');

const code6 = readCaptchaFromMessage(`『　267　』
セキュリティ番号入力画面で、上記3桁の数字を入力してください。
有効期限：2023/04/11 14:47`);
console.log(code6, code6 === '267');

const code7 = readCaptchaFromMessage('1234');
console.log(code7, code7 === '1234');

const code8 = readCaptchaFromMessage('Der SMS Code für Ihre Zahlung bei MyCompany in Höhe von EUR 99999.77 um 01.05.2023 16:11:02 ist 9401. Geben Sie den Code ein, nur wenn der Name des Händlers und der Betrag mit der von Ihnen gewünschten Zahlung übereinstimmen.');
console.log(code8, code8 === '9401');

const subject = readSubjectFromMessage('【美团】8758（登录验证码，请完成验证），如非本人操作，请忽略本短信。');
console.log(subject, subject === '【美团】');


