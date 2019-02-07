import EctoEnum

defenum Bizzer.UserRole, banned: 0, member: 1, worker: 2, editor: 3, admin: 4

defenum Bizzer.OriginType, bizzer: 0, chotot: 1, fsell: 2, rongbay: 3

defenum Bizzer.ReviewStatus,
  pending: 0,
  accepted: 1,
  rejected: 2,
  stopped: 3,
  deleted: 4,
  locked: 5

defenum Bizzer.ShopStatus,
  pending: 0,
  running: 1,
  stopped: 2,
  deleted: 3,
  locked: 4

defenum Bizzer.PropType, parent: 0, child: 1

defenum Bizzer.UserType, "ca-nhan": 0, "ban-chuyen": 1
defenum Bizzer.UserNeed, "can-ban": 0, "can-mua": 1

defenum Bizzer.AdimageStatus, unedit: 0, edited: 1, unneed: 2

defenum Bizzer.NotifyType,
  accept_adentry: 0,
  reject_adentry: 1,
  delete_adentry: 2,
  import_adentry: 3
