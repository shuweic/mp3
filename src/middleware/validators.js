export function validateUserPayload(body, isUpdate = false) {
  if (!isUpdate) {
    // Create mode: require name and email
    if (!body.name || body.name.trim() === '') {
      throw { status: 400, message: 'name is required' }
    }
    if (!body.email || body.email.trim() === '') {
      throw { status: 400, message: 'email is required' }
    }
  } else {
    // Update mode: if fields provided, ensure non-empty
    if (body.name !== undefined && (!body.name || body.name.trim() === '')) {
      throw { status: 400, message: 'name cannot be empty' }
    }
    if (body.email !== undefined && (!body.email || body.email.trim() === '')) {
      throw { status: 400, message: 'email cannot be empty' }
    }
  }
}

export function validateTaskPayload(body, isUpdate = false) {
  if (!isUpdate) {
    // Create mode: require name and deadline
    if (!body.name || body.name.trim() === '') {
      throw { status: 400, message: 'name is required' }
    }
    if (!body.deadline) {
      throw { status: 400, message: 'deadline is required' }
    }
  } else {
    // Update mode: if fields provided, ensure non-empty
    if (body.name !== undefined && (!body.name || body.name.trim() === '')) {
      throw { status: 400, message: 'name cannot be empty' }
    }
    if (body.deadline !== undefined && !body.deadline) {
      throw { status: 400, message: 'deadline cannot be empty' }
    }
  }
}

